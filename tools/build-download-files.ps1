# Rebuilds images/data/*.js - small script copies of every image in /images.
# They let the Download button work even when the site is opened by double-click.
# Run update-download-files.bat after you add or replace any image.
$root   = Split-Path -Parent $PSScriptRoot
$images = Join-Path $root 'images'
$out    = Join-Path $images 'data'
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out | Out-Null }
Get-ChildItem $out -Filter *.js | Remove-Item -Force
$n = 0
Get-ChildItem $images -Recurse -File |
  Where-Object { $_.Extension -match '^\.(jpe?g|png|webp|gif)$' -and $_.FullName -notmatch '\\images\\(data|icons)\\' } |
  ForEach-Object {
    $rel  = $_.FullName.Substring($images.Length + 1) -replace '\\', '/'
    $key  = "images/$rel"
    $ext  = $_.Extension.ToLower().TrimStart('.')
    $mime = if ($ext -eq 'jpg' -or $ext -eq 'jpeg') { 'image/jpeg' } else { "image/$ext" }
    $b64  = [Convert]::ToBase64String([IO.File]::ReadAllBytes($_.FullName))
    $jsKey = $key -replace '\\', '\\' -replace '"', '\"'
    $file = Join-Path $out (($rel -replace '/', '__') + '.js')
    [IO.File]::WriteAllText($file, "(window.__WC_IMG=window.__WC_IMG||{})[""$jsKey""]='data:$mime;base64,$b64';")
    $n++
  }
Write-Host "  Download files updated ($n images)." -ForegroundColor Cyan
