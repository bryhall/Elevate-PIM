
# Elevate-PIM
## SYNOPSIS
Provides a quick way to elevate an Azure AD Privileged Identity Management (PIM) role.

## DESCRIPTION
Provides a quick way to elevate an Azure AD Privileged Identity Management (PIM) role.
If no parameters are specified, the script will prompt for them as needed.  

## SYNTAX
### Default (Default)

```
Elevate-PIM [-AccountID <String>] [-Role <String[]>] [-Justification <String>] [-MaxMinutes <Int32>] [-TenantID <String>] [<CommonParameters>]
```
### ListOnly (ListOnly)
```
Elevate-PIM [-ListOnly] [<CommonParameters>]
```

## PARAMETERS
### -AccountID
UPN or GUID of Azure AD user.  
If omitted, the script will provide an Azure AD Modern Authentication prompt.
```
Type:                        String
Parameter Sets:              (All)
Aliases:
Required:                    False
Position:                    Named
Default value:               None
Accept pipeline input:       False
Accept wildcard characters:  False
```

### -Role
Exact name(s) of one or more Azure AD role to activate.  Enclose roles in quotes and separate multiple roles with comma (e.g., -Role "Conditional Access Administrator", "User Administrator").  
If omitted, the script will provide an Out-GridView of all available roles that the authenticated user is eligible for in PIM.
The user will select one (or more) roles to request.
```
Type:                        String[]
Parameter Sets:              Default
Aliases:
Required:                    False
Position:                    Named
Default value:               None
Accept pipeline input:       False
Accept wildcard characters:  False
```

### -Justification
Justification for request.  This is only used if the role activation requires justification.  
If omitted, the script will prompt for one if the Role Definition requires it.
```
Type:                        String
Parameter Sets:              Default
Aliases:
Required:                    False
Position:                    Named
Default value:               None
Accept pipeline input:       False
Accept wildcard characters:  False
```

### -MaxMinutes
If specified, sets the PIM request duration for the specified number of minutes.  If the role's defined maximum allowed value is less than the value provided here, the shorter amount will be used.  
If omitted, the request will use the maximum allowed by the role's definition.
```
Type:  Int32
Parameter Sets:              Default
Aliases:
Required:                    False
Position:                    Named
Default value:               0
Accept pipeline input:       False
Accept wildcard characters:  False
```

### -TenantID
GUID of the Azure AD tenant.  
If omitted, the script will use the Azure AD tenant associated with the authenticated user.
```
Type:                        String
Parameter Sets:              (All)
Aliases:
Required:                    False
Position:                    Named
Default value:               None
Accept pipeline input:       False
Accept wildcard characters:  False
```

### -ListOnly
If this switch is specified, the script will simply display a list of roles assigned to the user.
It will not perform any elevation.
```
Type:                        SwitchParameter
Parameter Sets:              ListOnly
Aliases:
Required:                    False
Position:                    Named
Default value:               False
Accept pipeline input:       False
Accept wildcard characters:  False
``` 

### CommonParameters
This cmdlet supports the common parameters: ```-Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable```. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).


## EXAMPLES
### EXAMPLE 1
```
PS C:\> Elevate-PIM
```
##### DESCRIPTION:
This method prompts the user for each required parameter.
It prompts the user for credentials and automatically looks up available PIM roles of the associated Azure AD tenant.  The user's available roles are displayed in an Out-GridView. The user selects 1 or more roles.
For each role, the role's defined maximum time will be used. If the roles requires justification, the user will be prompted to provide one. The maximum time defined for the role(s) will be used.


### EXAMPLE 2
```
PS C:\> Elevate-PIM -ListOnly

Roles that have the "Eligible (Active)" AssignmentState indicate that the PIM role is currently active.
Roles with only the "Active" AssignmentState indicate the user is persistently activated for the role (no need for PIM elevation).

RoleName                          AssignmentState    MaxMinutes JustificationRequired RoleDefinitionId                     MemberType
--------                          ---------------    ---------- --------------------- ----------------                     ----------
Compliance Administrator          Active                     60                  True 17315797-102d-40b4-93e0-432062caca18 Direct
Compliance Data Administrator     Active                     60                  True e6d1a23a-da11-4be4-9570-befc86d067a7 Direct
Conditional Access Administrator  Eligible                   60                  True b1be1c3e-b65d-4f19-8427-f6fa0d97feb9 Direct
Exchange Administrator            Eligible                   60                  True 29232cdf-9323-42fd-ade2-1d097af3e4de Direct
Global Administrator              Eligible                  240                  True 62e90394-69f5-4237-9190-012177145e10 Direct
Intune Administrator              Eligible (Active)         480                  True 3a2c62db-5318-420d-8d74-23affee5d9d5 Direct
User Administrator                Eligible                  480                  True fe930be7-5e62-47db-91af-98c3a49a38b1 Direct
```
##### DESCRIPTION:
This will simply output a list of the user's assigned PIM roles then exit.


### EXAMPLE 3
```
Elevate-PIM -TenantID 01020304-1234-abcd-abab-a1b2c3d4e5f6
```
##### DESCRIPTION:
This method is useful for guest access into another tenant.
It prompts for user credentials for tenant "01020304-1234-abcd-abab-a1b2c3d4e5f6" and provides an Out-GridView of available roles to the user.  The user selects 1 or more roles. For each role, the role's defined maximum time will be used.  If the roles require justification, the user will be prompted to provide one.
  
### EXAMPLE 4

```

Elevate-PIM -AccountID jdoe@contoso.com -Role "Exchange Administrator","User Administrator" -Justification "Change Control: AB123456" -MaxMinutes 120

ResourceId       : 0aa4c2af-52b6-43f1-aaa9-31c5fffb7458
RoleDefinitionId : 29232cdf-9323-42fd-ade2-1d097af3e4de
SubjectId        : 30228b81-1233-409e-8dfc-0bc4ab36239c
Type             : UserAdd
AssignmentState  : Active
Schedule         : class AzureADMSPrivilegedSchedule {
                     StartDateTime: 5/12/2021 4:02:35 PM
                     EndDateTime: 5/13/2021 5:02:34 AM
                     Type: Once
                     Duration: PT0S
                   }
Reason           : Change Control: AB123456


ResourceId       : 0aa4c2af-52b6-43f1-aaa9-31c5fffb7458
RoleDefinitionId : fe930be7-5e62-47db-91af-98c3a49a38b1
SubjectId        : 30228b81-1233-409e-8dfc-0bc4ab36239c
Type             : UserAdd
AssignmentState  : Active
Schedule         : class AzureADMSPrivilegedSchedule {
                     StartDateTime: 5/12/2021 4:02:35 PM
                     EndDateTime: 5/13/2021 12:02:34 AM
                     Type: Once
                     Duration: PT0S
                   }
Reason : Change Control: AB123456
```
  

##### DESCRIPTION:
This method will fully submit the elevation request without prompting the user for any additional information (except for the user's credentials).  It Attempts to activate both "Exchange Administrator" and "User Administrator" roles for user jdoe@contoso.com for 120 minutes (or the role's maximum, whichever is shorter).
"Change Control: AB123456" will be noted as the justification in the role activation request.
The user will be prompted to provide Modern Authentication credentials.


## INPUTS
None.


## OUTPUTS
None.


## NOTES
```
===========================================================
|| Version: 0.3                                          ||
|| Revision Date: 5/12/2021                              ||
|| Author: Bryan Hall                                    ||
|| Copyright: None                                       ||
|| Disclaimer: Use at your own risk.                     ||
===========================================================

This script requires the AzureADPreview module (https://docs.microsoft.com/en-us/powershell/azure/active-directory/install-adv2?view=azureadps-2.0) and must be run in a system with a user interface.

This is a requirement for the Out-GridView call used in the script.

While Out-GridView is supported on Linux or Mac, with the Microsoft.PowerShell.GraphicalTools (see https://devblogs.microsoft.com/powershell/out-gridview-returns/), the AzureADPreview module does not appear to function correctly on MacOS.
```
  

## RELATED LINKS
**PowerShell for Azure AD roles in Privileged Identity Management**
https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/powershell-for-azure-ad-roles

**Install Azure Active Directory PowerShell for Graph**
https://docs.microsoft.com/en-us/powershell/azure/active-directory/install-adv2?view=azureadps-2.0