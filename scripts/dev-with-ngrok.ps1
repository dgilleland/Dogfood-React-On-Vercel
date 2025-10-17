<#
Simple helper to start ngrok and the Next.js dev server for testing OAuth locally.

Usage (PowerShell):
  ./scripts/dev-with-ngrok.ps1

Requirements:
- ngrok must be installed and available on PATH (https://ngrok.com/download)
#>

Write-Host "Starting ngrok on port 3000..."
$ngrok = Start-Process -FilePath ngrok -ArgumentList "http 3000" -NoNewWindow -PassThru
Start-Sleep -Seconds 2

Write-Host "Starting Next.js dev server (npm run dev)..."
Start-Process -FilePath npm -ArgumentList "run", "dev" -NoNewWindow

Write-Host "ngrok and dev server started. Run 'ngrok http 3000' manually if this fails or check your PATH."
