#
# Module manifest for module 'k8s.Stats'
#
# Generated by: Amit Kshirsagar
#
# Generated on: 3/6/2020
#

@{

  # Script module or binary module file associated with this manifest.
  RootModule = 'k8s.Stats.psm1'
  
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
  Description = 'Get Stats for the Items.
  '
  
  # Minimum version of the PowerShell engine required by this module
  PowerShellVersion = '5.1'
  DotNetFrameworkVersion = '4.7.2'
  RequiredModules = @()
  FunctionsToExport = @("Get-Percentile","Measure-FullStats","Get-StatsReportCsv2Excel","Get-PercentileReportCsv2Excel","Compile-JMeterCsvReports")
  # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
  CmdletsToExport = @()
  # Variables to export from this module
  # VariablesToExport = @()
  # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
  AliasesToExport = @()
}