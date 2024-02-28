# Connexion à Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Mail.Send"

# Emplacement de votre fichier CSV
$CSV = "Chemin"
$users = Import-Csv -Path $CSV

foreach ($user in $users) {
    # Vérifie si l'utilisateur existe déjà
    $mail = "$user.Prenom" + "." + "$user.Nom" + "@sciencesu.online"
    $login = "$user.Prenom" + "." + "$user.Nom"

    $existingUser = Get-MgUser -Filter "userPrincipalName eq 'mail'" -ErrorAction SilentlyContinue
    
    if (-not $existingUser) {
        # Crée l'utilisateur s'il n'existe pas
        $newUser = New-MgUser -UserPrincipalName $mail -DisplayName "$user.Prenom $user.Nom" -MailNickname $login -AccountEnabled $true -PasswordProfile @{ ForceChangePasswordNextSignIn = $true; Password = "VotreMotDePasseTemporaire!" } -GivenName $user.FirstName -Surname $user.LastName

        # Envoie un email de bienvenue
        $message = @{
            Message = @{
                Subject = "Bienvenue dans notre entreprise"
                Body = @{
                    ContentType = "Text"
                    Content = "Bienvenue chez nous, $login ! Nous sommes très heureux de vous avoir parmi nous."
                }
                ToRecipients = @(
                    @{
                        EmailAddress = @{
                            Address = $user.Mail
                        }
                    }
                )
            }
            SaveToSentItems = $false
        }
        Send-MgUserMail -UserId $newUser.Id -BodyParameter $message
    }

    # Gestion des groupes
    foreach ($groupName in $user.Groups -split ',') {
        $existingGroup = Get-MgGroup -Filter "displayName eq '$groupName'" -ErrorAction SilentlyContinue
        if (-not $existingGroup) {
            # Crée le groupe s'il n'existe pas
            $newGroup = New-MgGroup -DisplayName $groupName -MailEnabled $true -MailNickname (New-Guid).Guid -SecurityEnabled $false -GroupTypes @("Unified")
        } else {
            $newGroup = $existingGroup
        }

        # Ajoute l'utilisateur au groupe
        Add-MgGroupMember -GroupId $newGroup.Id -DirectoryObjectId $newUser.Id -ErrorAction SilentlyContinue
    }
}

# Déconnexion de Microsoft Graph
Disconnect-MgGraph
