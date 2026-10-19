# Downloads every photo listed in images/image-list.txt from Unsplash.
# A photo is only replaced when the download succeeds, so nothing breaks if you are offline.
$ErrorActionPreference = 'Stop'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
$ProgressPreference = 'SilentlyContinue'

$root = Split-Path -Parent $PSScriptRoot
$list = Join-Path $root 'images\image-list.txt'
$ok = 0; $fail = 0

foreach ($raw in Get-Content $list) {
  $line = $raw.Trim()
  if (-not $line -or $line.StartsWith('#')) { continue }
  $parts = $line.Split('|') | ForEach-Object { $_.Trim() }
  if ($parts.Count -lt 2) { continue }
  $rel  = $parts[0]
  $id   = $parts[1]
  $w    = if ($parts.Count -gt 2 -and $parts[2]) { $parts[2] } else { '1080' }
  $dest = Join-Path $root ($rel -replace '/', '\')
  $dir  = Split-Path -Parent $dest
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $tmp  = "$dest.part"
  $url  = "https://unsplash.com/photos/$id/download?force=true&w=$w"
  Write-Host ("  {0,-45}" -f $rel) -NoNewline
  try {
    Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing -MaximumRedirection 10 -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
    if ((Get-Item $tmp).Length -lt 5000) { throw 'download too small' }
    Move-Item -Force $tmp $dest
    Write-Host 'OK' -ForegroundColor Green
    $ok++
  } catch {
    if (Test-Path $tmp) { Remove-Item -Force $tmp }
    Write-Host 'failed - kept the old image' -ForegroundColor Yellow
    $fail++
  }
}
Write-Host ''
Write-Host "  Done: $ok photos downloaded, $fail failed." -ForegroundColor Cyan
& (Join-Path $PSScriptRoot 'build-download-files.ps1')
