$ErrorActionPreference = "Continue"
Set-Location "D:\temp_ellesmere_repo"

Write-Host "=== Git Status ==="
git status

Write-Host "`n=== Staging all changes ==="
git add -A

Write-Host "`n=== Committing ==="
git commit -m "revert: remove all castbar-related work (CastBarExtras addon + Player Castbar mover)"

Write-Host "`n=== Pushing ==="
git push origin main

Write-Host "`n=== Done ==="
git log --oneline -3
