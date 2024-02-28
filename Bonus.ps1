# Se connecter à Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"

# Récupérer les informations de licence au niveau du tenant
$subscribedSkus = Get-MgSubscribedSku

# Afficher le nombre total de licences disponibles par type de licence
foreach ($sku in $subscribedSkus) {
    Write-Host "Type de licence: $($sku.SkuPartNumber) - Total disponible: $($sku.PrepaidUnits.Enabled) - Total consommé: $($sku.ConsumedUnits)"
}

# Récupérer tous les utilisateurs
$users = Get-MgUser -All

# Pour chaque utilisateur, récupérer les détails de la licence
foreach ($user in $users) {
    $licenses = Get-MgUserLicenseDetail -UserId $user.Id
    
    $licenseNames = $licenses | ForEach-Object { $_.SkuPartNumber }
    $licenseNamesString = $licenseNames -join ", "
    
    # Afficher l'identifiant de l'utilisateur et ses licences
    Write-Host "Utilisateur: $($user.DisplayName) - Licences: $licenseNamesString"
}

# Se déconnecter de Microsoft Graph à la fin
Disconnect-MgGraph

