# 重打 pi-ai 方舟兼容补丁
# 用途：DSH 升级 / npm 重装后，node_modules 会被重置，本补丁会丢失。
#       运行本脚本即可一键重打（幂等：已打过则跳过）。
# 生效条件：打完补丁需要【重启 DSH】——HMR 不会热载 node_modules。
$ErrorActionPreference = "Stop"

$target = "C:\Users\houxiaoyue\AppData\Roaming\npm\node_modules\@deepseek-ai\dsh\node_modules\@earendil-works\pi-ai\dist\api\openai-completions.js"

if (-not (Test-Path $target)) {
    Write-Host "[ERROR] 找不到 pi-ai 文件（dsh 安装路径可能已变化）：" -ForegroundColor Red
    Write-Host "        $target"
    exit 1
}

$text = [System.IO.File]::ReadAllText($target)
if ($text -match "isVolcengineArk") {
    Write-Host "[SKIP] 已打过补丁，无需重复执行。" -ForegroundColor Green
    exit 0
}

# 统一行尾为 LF，避免 CRLF 匹配失败
$text = $text -replace "`r`n", "`n"

$pairs = @(
    @(
        'const isAntLing = provider === "ant-ling" || baseUrl.includes("api.ant-ling.com");' + "`n" + '    const isNonStandard = isNvidia ||',
        'const isAntLing = provider === "ant-ling" || baseUrl.includes("api.ant-ling.com");' + "`n" + '    const isVolcengineArk = provider === "volcengine-ark" || baseUrl.includes("volces.com");' + "`n" + '    const isNonStandard = isVolcengineArk || isNvidia ||'
    ),
    @(
        'baseUrl.includes("chutes.ai") || isMoonshot || isCloudflareAiGateway || isTogether || isNvidia || isAntLing;',
        'baseUrl.includes("chutes.ai") || isMoonshot || isCloudflareAiGateway || isTogether || isNvidia || isAntLing || isVolcengineArk;'
    ),
    @(
        'requiresReasoningContentOnAssistantMessages: isDeepSeek,',
        'requiresReasoningContentOnAssistantMessages: isDeepSeek || isVolcengineArk,'
    ),
    @(
        'supportsStrictMode: !isMoonshot && !isTogether && !isCloudflareAiGateway && !isNvidia,',
        'supportsStrictMode: !isMoonshot && !isTogether && !isCloudflareAiGateway && !isNvidia && !isVolcengineArk,'
    )
)

foreach ($p in $pairs) {
    if (-not $text.Contains($p[0])) {
        Write-Host "[ERROR] 未找到待替换片段，pi-ai 版本可能已变化，请手动对照备份文件 openai-completions.js.original 处理：" -ForegroundColor Red
        Write-Host "        $($p[0].Substring(0, [Math]::Min(80, $p[0].Length)))..."
        exit 1
    }
    $text = $text.Replace($p[0], $p[1])
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($target, $text, $utf8NoBom)
Write-Host "[OK] 补丁已应用。请【重启 DSH】后生效。" -ForegroundColor Green
