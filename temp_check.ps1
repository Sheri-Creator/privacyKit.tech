$base = "c:\Users\shera\OneDrive\Documents\privacykit"
$files = @(
  "index.html", "about.html", "blog.html", "how-it-works.html", "privacy.html", "terms.html",
  "tools/password-checker.html", "tools/ip-lookup.html", "tools/breach-checker.html",
  "blog/how-strong-is-your-password.html", "blog/what-does-your-ip-address-reveal.html",
  "blog/what-is-a-data-breach.html", "blog/what-is-two-factor-authentication.html"
)

foreach ($f in $files) {
    $full = Join-Path $base $f
    if (Test-Path $full) {
        $content = Get-Content $full -Raw
        
        $canonical = if ($content -match '<link rel="canonical" href="([^"]+)"') { $Matches[1] } else { "" }
        $ogUrl = if ($content -match 'property="og:url" content="([^"]+)"') { $Matches[1] } else { "" }
        $ogImage = if ($content -match 'property="og:image" content="([^"]+)"') { $Matches[1] } else { "" }
        $title = if ($content -match '<title>([^<]+)<\/title>') { $Matches[1] } else { "" }
        
        $h1count = ([regex]::Matches($content, '(?i)<h1\b')).Count
        $inlineStyles = ([regex]::Matches($content, '(?i) style="[^"]+"')).Count
        
        $types = [regex]::Matches($content, '(?i)"@type"\s*:\s*"([^"]+)"') | Foreach {$_.Groups[1].Value} | Select -Unique
        $typesStr = $types -join ", "
        
        $ga = $content -match 'G-M2EF0M2GGF'
        $vercel = $content -match 'vercel'
        $online = $content -match 'privacykit\.online'

        Write-Host "FILE|$f|$canonical|$ogUrl|$ogImage|$title|$h1count|$ga|$vercel|$online|$inlineStyles|$typesStr"
    } else {
        Write-Host "FILE|$f MISSING"
    }
}

Write-Host "--- Root Files ---"
$robPath = Join-Path $base "robots.txt"
if (Test-Path $robPath) {
    $rob = Get-Content $robPath -Raw
    $gpt = $rob -match 'GPTBot'
    $claude = $rob -match 'ClaudeBot'
    $perp = $rob -match 'PerplexityBot'
    Write-Host "robots.txt|GPT:$gpt|Claude:$claude|Perp:$perp"
} else { Write-Host "robots.txt missing" }

$smPath = Join-Path $base "sitemap.xml"
if (Test-Path $smPath) {
    $sm = Get-Content $smPath -Raw
    $online = $sm -match 'privacykit\.online'
    $htmlExt = $sm -match '\.html<'
    Write-Host "sitemap.xml|Online:$online|htmlExt:$htmlExt"
} else { Write-Host "sitemap.xml missing" }

$llmsPath = Join-Path $base "llms.txt"
$llmsExists = Test-Path $llmsPath
Write-Host "llms.txt|$llmsExists"
if ($llmsExists) {
    $llms = Get-Content $llmsPath -Raw
    $tools = $llms -match 'tools/'
    Write-Host "llms.txt content tools: $tools"
}

$ogPath = Join-Path $base "og-image.svg"
Write-Host "og-image.svg|" (Test-Path $ogPath)

$redirPath = Join-Path $base "_redirects"
$redirExists = Test-Path $redirPath
Write-Host "_redirects|$redirExists"
if ($redirExists) {
    $redir = Get-Content $redirPath -Raw
    $contact = $redir -match '/contact-us'
    Write-Host "_redirects content contact: $contact"
}
