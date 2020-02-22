<#
    .DESCRIPTION

    
#>

function Print-Pyramid {
Param ([int] $height = 6,
       [char] $char = '*',
       [string] $name = $(throw "Required -name"),
       [string] $creator = "Dummy"
)
    Starting-Building -name $name
    for ($i = 0; $i -le $height; $i ++) {
        for ($j = 0; $j -le $height; $j ++) {
            if ($i -gt $j) {
                Write-Host $char -NoNewLine
            }
        }
        Write-Host ""
    }
    Finishing-Building -creator $creator
}

function Starting-Building {
Param (
       [string] $name = $(throw "Required -name")
)
    Write-Host ""
    Write-Host "Creating Pyramid for $name!!!"
}

function Finishing-Building {
Param (
       [string] $creator = "Dummy"
)
    Write-Host ""
    Write-Host "Creator: $creator"
}

# cls
# Write-Host ""
# Print-Pyramid -name Aarthi
# Write-Host ""
# Print-Pyramid -name Aarthi -char '0'
# Write-Host ""
# Print-Pyramid -name Aarthi -char '0' -creator Amit
# Write-Host ""
# $height = $( Read-Host "How tall u need your pyramid: " )
# Print-Pyramid -name Aarthi -char '0' -creator Amit -height $height
Write-Host ""
Print-Pyramid


