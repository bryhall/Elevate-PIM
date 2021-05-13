# Elevate-PIM
This function was written out of frustration. Using the Azure portal for requesting [**Privileged Identity Management (PIM)**](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure) role activations took [far too long with too many clicks](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-how-to-activate-role?tabs=new).  The script greatly simplifies the role activation process.

PIM is a feature of Azure Active Directory that provides time-based and approval-based role activation to mitigate the risks of excessive, unnecessary, or misused access permissions on resources that you care about.  Users that use PIM require [Azure AD Premium P2](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure#license-requirements) licenses.

## Requirements
The script was developed on Windows and has the following requirements:
1. User must have Azure AD PIM roles
2. [AzureADPreview](https://docs.microsoft.com/en-us/powershell/azure/active-directory/install-adv2?view=azureadps-2.0) module must be installed locally.
3. The PowerShell host must support *Out-GridView*.  Please feel free to modify the script to eliminate this call.
4. Run the function on Windows*

*Even with the [Microsoft.PowerShell.GraphicalTools](https://devblogs.microsoft.com/powershell/out-gridview-returns/) module installed (which enables Out-GridView on Linux and MacOS. installed on MacOS), the Azure AD Modern Authentication prompt that is called by the *Get-AzureADUser* command will fail on MacOS.  Please let me know if you know how to get this working on MacOS/Linux


## Quick Start
Simply run ``` Elevate-PIM``` without any parameters and the function will:
1. prompt for Azure AD credentials with a Modern Authentication window.
2. obtain a list of all available Azure AD roles assigned to the user.
3. display a PowerShell **Out-GridView** list of all available roles that the user can select to activate/elevate.  One or more roles may be selected.
4. process each role for activation.  For each role, the role's maximum activation time will be used.  If a Justification reason is required, it will prompt the user.

If you already know the role(s) that you want to elevate and the justification, you may specify them in the parameters.  For example, this command will elevate *jdoe@contoso.com* to both *User Administrator* and *Conditional Access Administrator* roles with the justification reason referencing "Service Request #AB12345":

    Elevate-PIM -AccountID jdoe@contoso.com -Role "User Administrator","Conditional Access Administrator" -Justification "Service Request #AB12345"

## Help
For more information, review the function's comment-based help or [**Elevate-PIM.md**](./_OnlineHelp/a/Elevate-PIM.md)



