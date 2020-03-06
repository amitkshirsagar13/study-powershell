function Get-Percentile {
  <#
  .SYNOPSIS
  Get Percentile Stats for the Array
  .DESCRIPTION
  Get Percentile Stats for the Array
  .PARAMETER Sequence
  Input Sequence Array Data
  .PARAMETER Percentile
  Percentile stats expected
  .EXAMPLE
  Import-Module .\Modules\k8s.Stats\1.0.0\k8s.Stats.psm1
  Get-Percentile -Sequence @(5,2,5,7,8,4,65,2,4,8,7) -Percentile 0.50
  .NOTES
  Author:  Amit Kshirsagar
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)] 
    [Double[]]$Sequence
    ,
    [Parameter(Mandatory)]
    [Double]$Percentile
  )
  $Sequence = $Sequence | Sort-Object
  [int]$N = $Sequence.Length
  Write-Verbose "N is $N"
  [Double]$Num = ($N - 1) * $Percentile + 1
  Write-Verbose "Num is $Num"
  $percentile = -1.0
  if ($num -eq 1) {
    $percentile = $Sequence[0]
  } elseif ($num -eq $N) {
    $percentile = $Sequence[$N-1]
  } else {
      $k = [Math]::Floor($Num)
      Write-Verbose "k is $k"
      [Double]$d = $num - $k
      Write-Verbose "d is $d"
      $percentile = $Sequence[$k - 1] + $d * ($Sequence[$k] - $Sequence[$k - 1])
  }
  return [math]::Round($percentile,2)
}

class MeasureStatObject {
  [Double[]]$Sequence = @()
  MeasureStatObject ([Double[]]$Sequence) {
    $this.Sequence = $Sequence
  }
  $Measure = -1
  $Minimum = -1
  $Maximum = -1
  $Average = -1
  $Count   = -1
  $Per50   = -1
  $Per90   = -1
  $Per99   = -1
}

function Measure-FullStats {
  <#
  .SYNOPSIS
  Get 50,90 and 99 Percentile Stats for the Array
  .DESCRIPTION
  Get 50,90 and 99Percentile Stats for the Array
  .PARAMETER Sequence
  Input Sequence Array Data
  .EXAMPLE
  Import-Module .\Modules\k8s.Stats\1.0.0\k8s.Stats.psm1
  ,@(5,2,5,7,8,4,65,2,4,8,7)|Measure-FullStats
  Measure-FullStats -Sequence @(5,2,5,7,8,4,65,2,4,8,7)
  .NOTES
  Author:  Amit Kshirsagar
  #>
  [CmdletBinding()]
  param (
    [parameter(mandatory=$true,ValueFromPipeline=$true)][Double[]]$Sequence
  )
  process {
    $MeasureObject = [MeasureStatObject]::new($Sequence);
    $MeasureObject.Measure = ($Sequence| Measure-Object -Minimum -Maximum -Average)
    $MeasureObject.Minimum = $MeasureObject.Measure.Minimum
    $MeasureObject.Maximum = $MeasureObject.Measure.Maximum
    $MeasureObject.Average = [math]::Round($MeasureObject.Measure.Average,2)
    $MeasureObject.Count = $MeasureObject.Measure.Count
    $MeasureObject.Per50 = Get-Percentile -Sequence $Sequence -Percentile 0.50
    $MeasureObject.Per50 = [math]::Round($MeasureObject.per50,2)
    $MeasureObject.Per90 = Get-Percentile -Sequence $Sequence -Percentile 0.90
    $MeasureObject.Per90 = [math]::Round($MeasureObject.per90,2)
    $MeasureObject.Per99 = Get-Percentile -Sequence $Sequence -Percentile 0.99
    $MeasureObject.Per99 = [math]::Round($MeasureObject.per99,2)
    return $MeasureObject;
  }
}

function Get-StatsReportCsv2Excel {
  <#
  .SYNOPSIS
  Get xslx report file from csv file format
  .DESCRIPTION
  Get xslx report file from csv file format
  .PARAMETER InputCsv
  Input Csv file
  .PARAMETER OutputXlsx
  output Xslx file
  .EXAMPLE
  Import-Module .\Modules\k8s.Stats\1.0.0\k8s.Stats.psm1
  Get-StatsReportCsv2Excel -InputCsv $csvReportFile -$OutputXlsx xslxReportFile
  .NOTES
  Author:  Amit Kshirsagar
  #>
  param (
    [parameter(mandatory=$true)][string]$InputCsv,
    [parameter(mandatory=$true)][string]$OutputXlsx
  )
  $delimiter = "," #Specify the delimiter used in the file
  $columnsCount = (Get-Content $InputCsv | Select-Object  -First 1).Split($delimiter).count
  $currentDir=Get-Location

  $excel = New-Object -ComObject excel.application
  $excel.sheetsInNewWorkbook = 1
  $workbook = $excel.Workbooks.Add()
  $worksheet = $workbook.worksheets.Item(1)

  $worksheet.name = "StatsReport"

  $j = 1
  for ($i = 1; $j -le $columnsCount; $j++) {
      $worksheet.Cells($i, $j).Interior.ColorIndex = 43
      $worksheet.Cells.Item($i, $j).Font.Size = 12
      $worksheet.Cells.Item($i, $j).Font.Bold = $True
      $worksheet.Cells.Item($i, $j).Font.Name = "Cambria"
      $worksheet.Cells.Item($i, $j).Font.ThemeFont = 1
      $worksheet.Cells.Item($i, $j).Font.ThemeColor = 4
      $worksheet.Cells.Item($i, $j).Font.ColorIndex = 55
      $worksheet.Cells.Item($i, $j).Font.Color = 8210719
  }
  
  # Build the QueryTables.Add command and reformat the data
  $TxtConnector = ("TEXT;" + "$currentDir/$InputCsv")
  $Connector = $worksheet.QueryTables.add($TxtConnector, $worksheet.Range("A1"))
  $query = $worksheet.QueryTables.item($Connector.name)
  $query.TextFileOtherDelimiter = $delimiter
  $query.TextFileParseType = 1
  $query.TextFileColumnDataTypes = , 1 * $worksheet.Cells.Columns.Count
  $query.AdjustColumnWidth = 1

  Write-Host "$currentDir/$OutputXlsx"
  # Execute & delete the import query
  $query.Refresh()
  $query.Delete()

  $DataforChart = $worksheet.Range("A1").CurrentRegion
  $DataforChart.Borders.LineStyle = 1

  Remove-Item -Path "$currentDir/$OutputXlsx"
  # Save & close the Workbook as XLSX.
  $Workbook.SaveAs("$currentDir/$OutputXlsx", 51)
  $excel.Quit()
}

