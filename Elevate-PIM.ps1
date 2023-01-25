<#PSScriptInfo
    .VERSION 0.4
    .GUID bc590fc4-6feb-43fa-8d5c-0b27a787f9d2
    .AUTHOR Bryan Hall
    .COMPANYNAME
    .COPYRIGHT (c) 2021 Bryan Hall
    .TAGS AzureAD PIM
    .LICENSEURI https://github.com/bryhall/Elevate-PIM/blob/main/LICENSE.md
    .PROJECTURI https://github.com/bryhall/Elevate-PIM
    .ICONURI 
    .EXTERNALMODULEDEPENDENCIES 
    .REQUIREDSCRIPTS 
    .EXTERNALSCRIPTDEPENDENCIES 
    .RELEASENOTES
#> 

#Requires -Module AzureADPreview

<#
.SYNOPSIS
    Provides a quick way to elevate an Azure AD Privileged Identity Management (PIM) role.

.DESCRIPTION
    Provides a quick way to elevate an Azure AD Privileged Identity Management (PIM) role.  If no parameters are specified, the script will prompt for them as needed.

.PARAMETER AccountID
    UPN or GUID of Azure AD user.
    If omitted, the script will provide an Azure AD Modern Authentication prompt.

.PARAMETER TenantID
    GUID of the Azure AD tenant.
    If omitted, the script will use the Azure AD tenant associated with the authenticated user.

.PARAMETER Role
    Exact name of an Azure AD role.  Enclose roles in quotes and seperate multiple roles with comma (e.g., -Role "Conditional Access Administrator","User Administrator").
    If omitted, the script will provide an Out-GridView of all available roles that the authenticated user is eligible for in PIM.  The user will select one (or more) roles to request.

.PARAMETER Justification
    Justification for request.  This is only used if the role activation requires justification.
    If omitted, the script will prompt for one if the Role Definition requires it.

.PARAMETER MaxMinutes
    If specified, sets the PIM request duration for the specified number of minutes.  If the role's defined maximum allowed value is less than the value provided here, the shorter amount will be used.
    If omitted, the request will use the maximum allowed by the role's definition.

.PARAMETER ListOnly
    If this switch is specified, the script will simply display a list of roles assigned to the user.  It will not perform any elevation.

.EXAMPLE
    Elevate-PIM

    -----------------------------------
    DESCRIPTION:
    This method prompts the user for each required parameter.  It prompts the user for credentials and automatically looks up available PIM roles of the associated Azure AD tenant.
    The user's available roles are displayed in an Out-GridView.  The user selects 1 or more roles. For each role, the role's defined maximum time will be used.
    If the roles requires justification, the user will be prompted to provide one.  The maximum time defined for the role(s) will be used.

.EXAMPLE
    Elevate-PIM -ListOnly
    
    Roles that have the "Eligible (Active)" AssignmentState indicate that the PIM role is currently active.
    Roles with only the "Active" AssignmentState indicate the user is persistently activated for the role (no need for PIM elevation).

    RoleName                         AssignmentState   MaxMinutes JustificationRequired RoleDefinitionId                     MemberType
    --------                         ---------------   ---------- --------------------- ----------------                     ----------
    Compliance Administrator         Active                    60                  True 17315797-102d-40b4-93e0-432062caca18 Direct    
    Compliance Data Administrator    Active                    60                  True e6d1a23a-da11-4be4-9570-befc86d067a7 Direct    
    Conditional Access Administrator Eligible                  60                  True b1be1c3e-b65d-4f19-8427-f6fa0d97feb9 Direct    
    Exchange Administrator           Eligible                  60                  True 29232cdf-9323-42fd-ade2-1d097af3e4de Direct    
    Global Administrator             Eligible                 240                  True 62e90394-69f5-4237-9190-012177145e10 Direct    
    Intune Administrator             Eligible (Active)        480                  True 3a2c62db-5318-420d-8d74-23affee5d9d5 Direct    
    User Administrator               Eligible                 480                  True fe930be7-5e62-47db-91af-98c3a49a38b1 Direct

    -----------------------------------
    DESCRIPTION:
    This will simply output a list of the user's assigned PIM roles then exit.


.EXAMPLE
    Elevate-PIM -TenantID "01020304-1234-abcd-abab-a1b2c3d4e5f6"

    -----------------------------------
    DESCRIPTION:
    This method is useful for guest access into another tenant.  It prompts for user credentials for tenant "01020304-1234-abcd-abab-a1b2c3d4e5f6" and provides an Out-GridView of available roles to the user.
    The user selects 1 or more roles. For each role, the role's defined maximum time will be used.  If the roles require justification, the user will be prompted to provide one.

.EXAMPLE
    Elevate-PIM -AccountID "jdoe@contoso.com" -Role "Exchange Administrator","User Administrator" -Justification "Change Control: AB123456" -MaxMinutes 15

    Role             : Exchange Administrator
    AssignmentState  : Active
    Duration         : 15 Minutes
    StartTime        : 1/25/2023 12:56:08 PM (Pacific Standard Time)
    EndTime          : 1/25/2023 1:11:06 PM (Pacific Standard Time)
    Justification    : Change Control: AB123456

    Role             : User Administrator
    AssignmentState  : Active
    Duration         : 15 Minutes
    StartTime        : 1/25/2023 12:56:08 PM (Pacific Standard Time)
    EndTime          : 1/25/2023 1:11:06 PM (Pacific Standard Time)
    Justification    : Change Control: AB123456

    -----------------------------------
    DESCRIPTION:
    This method will fully submit the elevation request without prompting the user for any additional information (except for the user's credentials).
    It Attempts to activate both "Exchange Administrator" and "User Administrator" roles for user jdoe@contoso.com for 15 minutes (or the role's maximum, whichever is shorter).
    "Change Control: AB123456" will be noted as the justification in the role activation request.  The user will be prompted to provide Modern Authentication credentials.

.NOTES
    This script requires the AzureADPreview module (https://docs.microsoft.com/en-us/powershell/azure/active-directory/install-adv2?view=azureadps-2.0) and must be run in a system with a user interface.
    This is a requirement for the Out-GridView call used in the script.
    
    While Out-GridView is supported on Linux or Mac, with the Microsoft.PowerShell.GraphicalTools (see https://devblogs.microsoft.com/powershell/out-gridview-returns/), the AzureADPreview module does not appear to function correctly on MacOS.

.LINK
    PowerShell for Azure AD roles in Privileged Identity Management
        https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/powershell-for-azure-ad-roles

.LINK
    Install Azure Active Directory PowerShell for Graph
        https://docs.microsoft.com/en-us/powershell/azure/active-directory/install-adv2?view=azureadps-2.0

.INPUTS
    None.

.OUTPUTS
    None.    
#>

[CmdletBinding(DefaultParameterSetName='Default')]

Param(
    [Parameter(ParameterSetName='Default',Position=0)]
    [Parameter(ParameterSetName='ListOnly',Position=0)]
    [String]$AccountID,

    [Parameter(ParameterSetName='Default',Position=1)]
    #[Parameter(ParameterSetName='CloseRequest',Position=1)] #For future use
    #If new roles are available, run either "Get-AzureADDirectoryRole | Select -Expand DisplayName"  or
    #"Get-AzureADMSPrivilegedRoleDefinition | Select -Expand DisplayName" to generate this list.
    [ValidateSet("Application Administrator","Application Developer","Authentication Administrator",
        "Azure AD Joined Device Local Administrator","Azure Information Protection Administrator",
        "Billing Administrator","Cloud Application Administrator","Compliance Administrator",
        "Compliance Data Administrator","Conditional Access Administrator","Customer LockBox Access Approver",
        "Directory Readers","Directory Synchronization Accounts","Exchange Administrator",
        "Exchange Recipient Administrator","Global Administrator","Global Reader","Groups Administrator",
        "Helpdesk Administrator","Intune Administrator","License Administrator","Message Center Reader",
        "Password Administrator","Privileged Role Administrator","Reports Reader","Search Administrator",
        "Security Administrator","Security Reader","Service Support Administrator","SharePoint Administrator",
        "Skype for Business Administrator","Teams Administrator","Teams Communications Administrator",
        "Teams Communications Support Engineer","Teams Communications Support Specialist",
        "Teams Devices Administrator","User Administrator")]    
    [String[]]$Role,

    [Parameter(ParameterSetName='Default',Position=2,Mandatory=$true)]
    [String]$Justification,

    [Parameter(ParameterSetName='Default')]
    [Int]$MaxMinutes,

    [String]$TenantID,
    
    [Parameter(ParameterSetName='ListOnly')]
    [Switch]$ListOnly
)

#Splat the parameters
$ConnectParams = @{}
If ($AccountID) {
    $ConnectParams += @{AccountID = $AccountID}
} #End If
If ($TenantID) {
    $ConnectParams += @{TenantID = $TenantID}
} #End If


Try {
    #Connect to AzureAD (preview)
    Write-Warning "If interactive credentials are required, a Microsoft Online authentication prompt will appear.  Please be aware that this may sometimes appear behind other windows."
    $ConnectionInfo = Connect-AzureAD @ConnectParams -ErrorAction Stop

    #Get the User object
    $User = Get-AzureADUser -ObjectId $ConnectionInfo.Account -ErrorAction Stop

    #Get all role definitions in Azure AD tenant
    Write-Verbose "Getting Azure AD Role Definitions and Settings."
    $RoleDefinitions = Get-AzureADMSPrivilegedRoleDefinition -ProviderId 'aadRoles' -ResourceId $ConnectionInfo.TenantID -ErrorAction Stop | Sort-Object -Property DisplayName | Select-Object -Property DisplayName,ID
    $RoleSettings    = Get-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Filter "ResourceId eq '$($ConnectionInfo.TenantID)'"

    #Get all roles that the user has assigned
    Write-Verbose "Getting Azure AD Role Assignments."
    $UserRoles = Get-AzureADMSPrivilegedRoleAssignment -ProviderId 'aadRoles' -ResourceId $ConnectionInfo.TenantID -Filter "SubjectID eq '$($User.ObjectID)'" -ErrorAction Stop | Select-Object -Property MemberType,
        AssignmentState,
        @{N="RoleName";E={$xRole = $_.RoleDefinitionID;($RoleDefinitions | Where-Object {$_.Id -eq $xRole}).DisplayName}},
        #@{N="RoleID";E={$xRole = $_.RoleDefinitionID;($RoleDefinitions | Where-Object {$_.Id -eq $xRole}).Id}},
        RoleDefinitionID | Sort-Object -Property Rolename,AssignmentStatus

    If (@($UserRoles).Count -eq 0) {
        Write-Warning "No roles are available for user: $($User.UserPrincipalName)."
        Break
    } #End If
} Catch {
    Write-Warning $_.Exception.Message
    Break
} #End Try..Catch

#Show a normalized list of roles that the user has
Write-Verbose "Normalizing User's List of Available Azure AD Role Assignments."
$AvailableUserRoles = $UserRoles | Select-Object -Unique RoleDefinitionId | ForEach {
    $xRoleID = $_.RoleDefinitionID

    $xMaxGrantPeriod = $RoleSettings | Where-Object {$_.RoleDefinitionID -eq $xRoleID} | Select-Object -ExpandProperty UserMemberSettings | Where-Object {$_.RuleIdentifier -eq 'ExpirationRule'} | Select-Object -ExpandProperty Setting | ConvertFrom-Json | Select-Object -ExpandProperty MaximumGrantPeriodInMinutes
    [bool]$xJustificationRequired = $RoleSettings | Where-Object {$_.RoleDefinitionID -eq $xRoleID} | Select-Object -ExpandProperty UserMemberSettings | Where-Object {$_.RuleIdentifier -eq 'JustificationRule'} | Select-Object -ExpandProperty Setting | ConvertFrom-Json | Select-Object -ExpandProperty Required

    $xRoleLoop = @($UserRoles | Where-Object {$_.RoleDefinitionId -eq $xRoleID})
    If ($xRoleLoop.count -gt 1) {
        $xRoleLoop[0] | Select-Object -Property Rolename,
        @{N="AssignmentState";E={"Eligible (Active)"}},
        @{N="MaxMinutes";E={$xMaxGrantPeriod}},
        @{N="JustificationRequired";E={$xJustificationRequired}},
        RoleDefinitionID,
        MemberType
    } Else {
        $xRoleLoop | Select-Object -Property Rolename,
        AssignmentState,
        @{N="MaxMinutes";E={$xMaxGrantPeriod}},
        @{N="JustificationRequired";E={$xJustificationRequired}},
        RoleDefinitionID,
        MemberType
    } #End If..Else
} #End $AvailableUserRoles

#If ListOnly was specified, display the user's available roles then exit.
If ($PSBoundParameters['ListOnly']) {
    Write-Verbose "Switch `"ListOnly`" specified.  These are the user's assigned roles."
    Write-Host -ForegroundColor Cyan "`nRoles that have the `"Eligible (Active)`" AssignmentState indicate that the PIM role is currently active."
    Write-Host -ForegroundColor Cyan "Roles with only the `"Active`" AssignmentState indicate the user is persistently activated for the role (no need for PIM elevation)."
    $AvailableUserRoles | Format-Table -AutoSize
    Break
} #End If..Else

#Prompt for selection, if not specified at runtime
$SelectedRole = @()
If ($PSBoundParameters.ContainsKey('Role')) {
    Write-Verbose "Selecting the Role(s) Specified in the Runtime Parameter"
    ForEach ($xRole in $Role) {
        $TempSelectedRole = $AvailableUserRoles | Where-Object {$_.RoleName -eq $xRole}
        If (-not $TempSelectedRole) {
            Write-Warning "Either the role could not be found or it is not available to the user:  $xRole"
            Continue
        } Else {
            $SelectedRole += $TempSelectedRole
        } #End If..Else
    } #End ForEach
} Else {
    Write-Verbose "Prompting for Role Selection(s)."
    $SelectedRole = $AvailableUserRoles | Sort-Object -Property AssignmentStat | Out-GridView -OutputMode Multiple -Title "Select an Eligible role"
} #End If..Else

$SelectedRole | ForEach-Object {
    If ($_.AssignmentState -match '(Active)') {
        Write-Host -ForegroundColor Magent "The $($SelectedRole.RoleName) role is already active."
    } Else {
        If (($MaxMinutes) -and ($MaxMinutes -le $_.MaxMinutes)) {
            $RequestDuration = $MaxMinutes
        } Else {
            $RequestDuration = $_.MaxMinutes
        }

        #Get the role definition schedule
        $Schedule               = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
        $Schedule.Type          = "Once"
        $Schedule.StartDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        $Schedule.endDateTime   = (Get-Date).AddMinutes($RequestDuration).ToUniversalTime()

        #Splat the parameters
        $RequestParams = @{
            ProviderId       = 'aadRoles'
            ResourceID       = $ConnectionInfo.TenantID
            RoleDefinitionId = $_.RoleDefinitionID 
            SubjectId        = $User.ObjectID
            Type             = 'UserAdd'
            AssignmentState  = 'Active'
            Schedule         = $Schedule
        } #End Splat

        #Prompt for Justification if the assignment requires it
        If ($_.JustificationRequired -eq $True) {
            #Prompt for a reason if it was not already supplied.
            If (-Not $Justification) {
                $Justification = Read-Host "Provide a justification (required)"
            } #End If
            $RequestParams += @{
                Reason = $Justification
            } #End Splat
        } #End If

        #Submit request for the role elevation.
        Write-Verbose "Requesting Azure AD Role Assignment"
        $AssignmentResults = Open-AzureADMSPrivilegedRoleAssignmentRequest @RequestParams -ErrorAction Stop
        If ($null -ne $AssignmentResults) {
            #Get UTC Offset of current time zone
            Try {
                $UTCOffset = (Get-TimeZone -ErrorAction Stop).BaseUTCOffset.Hours
                $LocalTZ = (Get-TimeZone).Id
            } Catch {
                $UTCOffset = 0
                $LocalTZ = 'UTC'
            } #End Try..Catch
            
            #Output assignment results
            $AssignmentResults | Select-Object -Property @{N='Role';E={$RoleDefinitions.Where{$_.Id -eq $AssignmentResults.RoleDefinitionId}.DisplayName}},
                AssignmentState,
                @{N='StartTime';E={"{0} ({1})" -f (Get-Date $AssignmentResults.Schedule.StartDateTime).AddHours($UTCOffset),$LocalTZ}},
                @{N='EndTime';E={"{0} ({1})" -f (Get-Date $AssignmentResults.Schedule.EndDateTime).AddHours($UTCOffset),$LocalTZ}},
                @{N='Duration';E={"{0} Minutes" -f [math]::Round((New-TimeSpan -Start $AssignmentResults.Schedule.StartDateTime -End $AssignmentResults.Schedule.EndDateTime).TotalMinutes,0.5)}},
                @{N='Justification';E={$Justification}}
        } #End If
    } #End If..Else
} #End ForEach