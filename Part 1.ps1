# Demande du nom de la première OU à l'utilisateur
$OU = Read-Host "Entrez le nom de la nouvelle OU principale"
$testOU = Get-ADOrganizationalUnit -SearchBase 'DC=projet-fyc,DC=local' -Filter "Name -eq '$OU'" -ErrorAction SilentlyContinue
if (-not $testOU ) {
    # Création de l'OU principale et des sous-OU si elle n'existe pas
    $OU = New-ADOrganizationalUnit -Name $ouName -PassThru
    New-ADOrganizationalUnit -Name "Ordinateurs" -Path $OU.DistinguishedName
    New-ADOrganizationalUnit -Name "Utilisateurs" -Path $OU.DistinguishedName
    New-ADOrganizationalUnit -Name "Groupes" -Path $OU.DistinguishedName
} else {
    Write-Host "L'OU $OU existe déjà elle n'est pas recréée"
}

# Demande du mot de passe par défaut pour les nouveaux utilisateurs
$defaultPassword = Read-Host "Entrez le mot de passe par défaut pour les nouveaux utilisateurs" -AsSecureString

# Emplacement du fichier CSV
$CSV = "C:\CSV\csv.csv"

# Importation des utilisateurs à partir du CSV
$users = Import-Csv $CSV

foreach ($user in $users) {
    $username = "$user.Prenom" + "." + "$user.Nom"
    $userDN = "CN=$username,OU=Utilisateurs," + "$OU"
    $password = $defaultPassword
    $userExists = Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue

    if (-not $userExists) {
        # Création de l'utilisateur s'il n'existe pas
        New-ADUser -Name $username -GivenName $user.Prenom -Surname $user.Nom -UserPrincipalName "$username@projet-fyc.local" -SamAccountName $username -DisplayName "$user.Prenom $user.Nom" -Path $userDN -AccountPassword $password -ChangePasswordAtLogon $true -Enabled $true
    }

    # Gestion des groupes
    $groups = $user.groupes -split ','
    foreach ($group in $groups) {
        $groupeexitste = Get-ADGroup -Filter "Name -eq '$group'" -ErrorAction SilentlyContinue
        if (-not $groupeexitste) {
            # Création du groupe s'il n'existe pas
            New-ADGroup -Name $group -GroupScope Global -Path "OU=Groupes," + "$OU"
        }
        # Ajout de l'utilisateur au groupe
        Add-ADGroupMember -Identity $group -Members $username -ErrorAction SilentlyContinue
    }
}
