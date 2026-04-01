$ErrorActionPreference = "Stop"
$down = "G:\down"
$srcRoot = $null
foreach ($d in [System.IO.Directory]::GetDirectories($down)) {
  $hits = [System.IO.Directory]::GetFiles($d, "*2026-03-31.md")
  if ($hits.Count -gt 0) { $srcRoot = $d; break }
}
if (-not $srcRoot) { throw "Could not find source folder with *2026-03-31.md under G:\down" }

$repoRoot = Split-Path $PSScriptRoot -Parent
$zhixingli = -join ([char]0x6267, [char]0x884C, [char]0x529B)
$reqSeg = "01-" + [char]0x9700 + [char]0x6C42
$destBase = Join-Path $repoRoot "projects"
$destBase = Join-Path $destBase $zhixingli
$destBase = Join-Path $destBase $reqSeg
$destBase = Join-Path $destBase "references"
$docs = Join-Path $destBase "docs"
$images = Join-Path $destBase "images"
New-Item -ItemType Directory -Force -Path $docs, $images | Out-Null

foreach ($f in [System.IO.Directory]::GetFiles($srcRoot, "*.md")) {
  $n = [System.IO.Path]::GetFileName($f)
  if ($n -like "*v1.1*") {
    Copy-Item -LiteralPath $f -Destination (Join-Path $docs $n) -Force
    Write-Host "Copied doc:" $n
  }
}

$design = $null
$maxPng = 0
foreach ($sd in [System.IO.Directory]::GetDirectories($srcRoot)) {
  $pngs = [System.IO.Directory]::GetFiles($sd, "*.png", [System.IO.SearchOption]::AllDirectories)
  if ($pngs.Length -gt $maxPng) { $maxPng = $pngs.Length; $design = $sd }
}
if (-not $design -or $maxPng -eq 0) { throw "No design PNG subtree found under $srcRoot" }

$allPng = Get-ChildItem -LiteralPath $design -Recurse -Filter "*.png" | Sort-Object FullName
$i = 1
foreach ($png in $allPng) {
  $rel = $png.FullName.Substring($design.Length).TrimStart("\")
  $flat = $rel.Replace("\", "_").Replace("/", "_")
  $safe = $i.ToString("00") + "-" + $flat
  $dest = Join-Path $images $safe
  Copy-Item -LiteralPath $png.FullName -Destination $dest -Force
  Write-Host $dest
  $i++
}
Write-Host "Done. PNG count:" ($i - 1)
