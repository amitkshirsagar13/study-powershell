#
# Module manifest for module 'k8s'
#
# Generated by: Amit Kshirsagar
#
# Generated on: 2/23/2020
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'k8s.psm1'
    
    # Version number of this module.
    ModuleVersion = '1.0.0'
    
    # Supported PSEditions
    CompatiblePSEditions = 'Core', 'Desktop'
    
    # Author of this module
    Author = 'Amit Kshirsagar'
    
    # Company or vendor of this module
    CompanyName = 'K8Clusters'
    
    # Copyright statement for this module
    Copyright = 'K8Clusters.'
    
    # Description of the functionality provided by this module
    Description = 'K8Clusters Automation Scripts - Cmdlets to manage resources in Azure. This module is compatible with WindowsPowerShell and PowerShell Core.
    '
    
    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'
    DotNetFrameworkVersion = '4.7.2'
    RequiredModules = @("Az","k8s.SecretValueText","k8s.AzKeyVault","k8s.Stats")
    FunctionsToExport = @()
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()
    # Variables to export from this module
    # VariablesToExport = @()
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()
}