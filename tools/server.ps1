# Tiny local web server (no install needed) so downloads work while you build.
$root = (Resolve-Path (Split-Path -Parent $PSScriptRoot)).Path
$mime = @{
  '.html'='text/html; charset=utf-8'; '.css'='text/css; charset=utf-8'; '.js'='application/javascript; charset=utf-8'
  '.json'='application/json'; '.txt'='text/plain; charset=utf-8'; '.md'='text/plain; charset=utf-8'
  '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.png'='image/png'; '.gif'='image/gif'; '.webp'='image/webp'
  '.svg'='image/svg+xml'; '.ico'='image/x-icon'; '.woff'='font/woff'; '.woff2'='font/woff2'
}
$listener = New-Object System.Net.HttpListener
$port = 8080
foreach ($p in 8080, 8081, 8090, 5500) {
  try { $listener = New-Object System.Net.HttpListener; $listener.Prefixes.Add("http://localhost:$p/"); $listener.Start(); $port = $p; break } catch { }
}
if (-not $listener.IsListening) { Write-Host 'Could not start the server (ports busy).' -ForegroundColor Red; exit 1 }
Write-Host "  Website running:  http://localhost:$port/" -ForegroundColor Green
Start-Process "http://localhost:$port/index.html"
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $res = $ctx.Response
  try {
    $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
    if ($rel -eq '') { $rel = 'index.html' }
    $file = [IO.Path]::GetFullPath((Join-Path $root $rel))
    if ((Test-Path $file -PathType Container)) { $file = Join-Path $file 'index.html' }
    if ($file.StartsWith($root) -and (Test-Path $file -PathType Leaf)) {
      $bytes = [IO.File]::ReadAllBytes($file)
      $ext = [IO.Path]::GetExtension($file).ToLower()
      $res.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
      $res.Headers.Add('Cache-Control', 'no-cache')
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $res.StatusCode = 404
      $msg = [Text.Encoding]::UTF8.GetBytes('Not found')
      $res.OutputStream.Write($msg, 0, $msg.Length)
    }
  } catch { $res.StatusCode = 500 }
  finally { $res.Close() }
}
