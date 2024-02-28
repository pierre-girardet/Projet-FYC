Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Mail.Send"

$MembershipRule = "(user.mail -contains '@sciencesu.online')"

New-MgGroup -DisplayName "Nom" -Description "Description" ` 
-MailEnabled:$true `
-SecurityEnabled:$False `
-MailNickname "LoginMail" `
-GroupTypes "DynamicMembership", "Unified" `
-MembershipRule $MembershipRule `
-MembershipRuleProcessingState "On"

Disconnect-MgGraph




New-GPO -Name "U_Raccourcis"

Set-GPRegistryValue -Name "U_Raccourcis" -Key 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop\AdminComponent' -ValueName 'Add' -Value 'apple.com'

Get-GPO -Name "U_Raccourcis" | New-GPLink -target “OU=Utilisateurs,OU=Projet-Fyc,DC=projet-fyc,DC=local” -LinkEnabled Yes


