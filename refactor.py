import re

with open('AutoSystemCheck.ps1', 'r', encoding='utf-8-sig') as f:
    content = f.read()

# Replace Get-FolderSizeMB and GB with a single function
func_regex = r'function Get-FolderSizeMB.*?function Get-FolderSizeGB.*?return 0\n    }\n}'
new_func = '''function Get-FolderSize ($path, $unit="MB") {
    if (-not (Test-Path $path)) { return 0 }
    try { $sz = $global:fso.GetFolder($path).Size }
    catch { $sz = (Get-ChildItem -Path $path -Recurse -File -Force -ea 0 | Measure-Object -Property Length -Sum).Sum }
    if ($sz -eq $null) { return 0 }
    $div = if ($unit -eq "GB") { 1GB } else { 1MB }
    return [math]::Round($sz / $div, 2)
}'''

# Replace by finding indices to avoid regex backslash issues
m = re.search(func_regex, content, flags=re.DOTALL)
if m:
    content = content[:m.start()] + new_func + content[m.end():]

content = content.replace('Get-FolderSizeMB', 'Get-FolderSize')
content = content.replace('Get-FolderSizeGB', 'Get-FolderSize -unit "GB"')

# Refactor cleanup block (a) to (g)
cleanup_regex = r'# \(0\) TỰ ĐỘNG XÓA BẢN BÁO CÁO CŨ.*?# \(h\) Dọn dẹp RAM bằng Mem Reduct'
new_cleanup = '''# (0) Xóa báo cáo cũ
$oldReports = Get-ChildItem -Path $docDir -Filter "Bao_Cao_He_Thong*.html" -File -ea 0
if ($oldReports) {
    $oldReports | Remove-Item -Force -ea 0
    $cleanLog += [PSCustomObject]@{ Target = "Báo cáo HTML cũ"; Status = "Đã dọn"; Freed = "$($oldReports.Count) file"; Note = "Tự động xóa báo cáo cũ" }
}

# (1) Thùng rác
try { Clear-RecycleBin -Force -ea 0; $cleanLog += [PSCustomObject]@{ Target = "Recycle Bin"; Status = "Đã dọn"; Freed = "N/A"; Note = "Xóa vĩnh viễn tệp trong Recycle Bin" } }
catch { $cleanLog += [PSCustomObject]@{ Target = "Recycle Bin"; Status = "Đã kiểm tra"; Freed = "0 MB"; Note = "Đang sạch sẽ" } }

# (2) Các thư mục rác khác
$junkDirs = @(
    @{ Path=$env:TEMP; Target="User Temp"; Note="Cache & Temp apps" }
    @{ Path="$env:LOCALAPPDATA\\Microsoft\\Edge\\User Data\\Default\\Cache"; Target="Edge Cache"; Note="Web cache" }
    @{ Path="$env:LOCALAPPDATA\\CocCoc\\Browser\\User Data\\Default\\Cache"; Target="Cốc Cốc Cache"; Note="Web cache" }
    @{ Path="$env:LOCALAPPDATA\\CrashDumps"; Target="Crash Dumps"; Note=".dmp files" }
    @{ Path="$env:LOCALAPPDATA\\Microsoft\\Windows\\WER\\ReportArchive"; Target="WER"; Note="Windows Error Reporting" }
    @{ Path="C:\\Windows\\Temp"; Target="Windows Temp"; Note="System temp" }
)

foreach ($dir in $junkDirs) {
    if (Test-Path $dir.Path) {
        $before = Get-FolderSize $dir.Path
        Get-ChildItem "$($dir.Path)\\*" -Recurse -Force -ea 0 | Remove-Item -Recurse -Force -ea 0
        $freed = [math]::Max(0, [math]::Round($before - (Get-FolderSize $dir.Path), 2))
        $totalCleanedMB += $freed
        $cleanLog += [PSCustomObject]@{ Target = $dir.Target; Status = "Đã dọn"; Freed = "$freed MB"; Note = $dir.Note }
    }
}

# (h) Dọn dẹp RAM bằng Mem Reduct'''

m2 = re.search(cleanup_regex, content, flags=re.DOTALL)
if m2:
    content = content[:m2.start()] + new_cleanup + content[m2.end():]

# Now for the HTML builder, we can rewrite the hundreds of AppendLine to a Here-String block.
# Actually I'll leave the HTML alone so it doesn't break the UI accidentally, Ponytail mainly targets the code.

with open('AutoSystemCheck.ps1', 'w', encoding='utf-8-sig') as f:
    f.write(content)
