$items = Get-WmiObject -Query "Select * from Win32_StartupCommand"
$consoleWidth = $host.UI.RawUI.WindowSize.Width
$script:selectedIndex = 0
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"

function DrawInterface {
    cls
    $date = Get-Date -Format "yyyy-dd-MM HH:mm:ss"
    $title = "- Startup Manager -"
    Write-Host (" " * ($consoleWidth / 2 - $title.Length) + $title + " " * ($consoleWidth / 2 - $date.Length) + $date + "`n") -BackgroundColor White -ForegroundColor Black

    for ($i = 0; $i -lt $items.Count; $i++) {
        if ($i -eq $script:selectedIndex) {
            Write-Host (" " * 3 + $items[$i].Caption + " " * ($consoleWidth - $items[$i].Caption.Length - 80)) -BackgroundColor White -ForegroundColor Black
        } else {
            Write-Host (" " * 3 + $items[$i].Caption)
        }
    }
}

function UpdateSelection($up) {
    if ($up) {
        if ($script:selectedIndex -gt 0) {
            $script:selectedIndex--
        }
    } else {
        if ($script:selectedIndex -lt ($items.Count - 1)) {
            $script:selectedIndex++
        }
    }
    DrawInterface
}

function ElementInfo {
    cls
    $title = "- Object Info -"
    Write-Host (" " * ($consoleWidth / 2 - $title.Length) + $title + " " * ($consoleWidth / 2) + "`n") -BackgroundColor White -ForegroundColor Black
    Write-Host (" " * 3 + "Name:" + "`t" + "$($items[$script:selectedIndex].Caption)")
    Write-Host (" " * 3 + "Execute:" + "`t" + "$($items[$script:selectedIndex].Command)")
    Write-Host ("`n" * 3 + " " * 3 + "Press any key to continue ...")
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") > $null
    DrawInterface
}

function AddElement {
    cls
    $title = "- Add New Element -"
    Write-Host (" " * ($consoleWidth / 2 - $title.Length) + $title + " " * ($consoleWidth / 2) + "`n") -BackgroundColor White -ForegroundColor Black

    $Caption = Read-Host -Prompt '  Name'
    $Command = Read-Host -Prompt '  Execute'

    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $Caption -Value $Command
    
    $script:items = Get-WmiObject -Query "Select * from Win32_StartupCommand"

    DrawInterface
}

# Update Element
function UpdateElement {
    cls
    $title = "- Update Element -"
    Write-Host (" " * ($consoleWidth / 2 - $title.Length) + $title + " " * ($consoleWidth / 2) + "`n") -BackgroundColor White -ForegroundColor Black

    $field1 = New-Object System.Management.Automation.Host.FieldDescription "Name" > $null
    $field1.Label = "  Name" > nul
    $field1.DefaultValue = $items[$selectedIndex].Caption > $null
    $field1.SetParameterType([string]) > $null
    $field1.HelpMessage = "Enter the new name for the startup command" > $null

    $field2 = New-Object System.Management.Automation.Host.FieldDescription "Execute" > $null
    $field2.Label = "  Execute" > $null
    $field2.DefaultValue = $items[$selectedIndex].Command > $null
    $field2.SetParameterType([string]) > $null
    $field2.HelpMessage = "Enter the new execute command for the startup command" > $null

    $result = $host.UI.Prompt("Update element", "Update the selected startup command:", [System.Management.Automation.Host.FieldDescription[]]@($field1, $field2))

    $Caption = $result["Name"]
    $Command = $result["Execute"]

    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $items[$selectedIndex].Caption
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $Caption -Value $Command

    $script:items = Get-WmiObject -Query "Select * from Win32_StartupCommand"

    DrawInterface
}

# Delete Element
function DeleteElement {
    do {
        cls
        $title = "- Delete confirmation -"
        Write-Host (" " * ($consoleWidth / 2 - $title.Length) + $title + " " * ($consoleWidth / 2) + "`n") -BackgroundColor White -ForegroundColor Black
        Write-Host (" " * 3 + "Name:" + "`t" + "$($items[$script:selectedIndex].Caption)")
        Write-Host (" " * 3 + "Execute:" + "`t" + "$($items[$script:selectedIndex].Command)" + "`n")
        $confirm = Read-Host "   Are you sure to delete? It cannot to undone! $($items[$selectedIndex].Caption)? (y/n)"
        if ($confirm -eq 'y') {
            Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $items[$selectedIndex].Caption
            $script:items = Get-WmiObject -Query "Select * from Win32_StartupCommand"
            break;
        }
        if ($confirm -eq 'n') {
            break;
        }
    }
    until (true)
    DrawInterface
}

function HandleKey($key) {
    switch ($key.VirtualKeyCode) {
        38 { UpdateSelection($true) }   # Up
        40 { UpdateSelection($false) }  # Down
        13 { ElementInfo }              # Enter
        65 { AddElement }               # A
        46 { DeleteElement }            # Del
        (116, 82) { RefreshList }       # F5 and R
        87 { UpdateElement }            # W
    }
}

DrawInterface

do {
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    HandleKey($key)
}
until ($key.VirtualKeyCode -eq 27)  # Exit when Esc is pressed