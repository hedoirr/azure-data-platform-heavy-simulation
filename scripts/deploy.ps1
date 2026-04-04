param(
    [string]$ResourceGroupName = "rg-sales-platform-dev",
    [string]$TemplateFile = "./infra/bicep/main.bicep",
    [string]$ParameterFile = "./infra/bicep/parameters/dev.json"
)

Write-Host "Starting deployment..." -ForegroundColor Cyan

az deployment group create `
  --resource-group $ResourceGroupName `
  --template-file $TemplateFile `
  --parameters @$ParameterFile

Write-Host "Deployment finished." -ForegroundColor Green