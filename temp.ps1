Add-Type -AssemblyName System.Windows.Forms

# Function to search and list apps
function SearchOrListApps {
    param (
        [string]$query,
        [bool]$isInstalled = $false
    )

    try {
        $results = if ($isInstalled) {
            winget list $query
        } else {
            winget search $query
        }

        if ($results) {
            $listBox.Items.Clear()
            foreach ($result in $results | Select-Object -Skip 2) {
                $listBox.Items.Add($result)
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("No results found for '$query'", "No Results", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Create a new PowerShell GUI window
$form = New-Object System.Windows.Forms.Form
$form.Text = "Winget GUI"
$form.Width = 610
$form.Height = 400

# Add a text box and a search button
$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Location = New-Object System.Drawing.Point(10, 10)
$searchBox.Width = 360
$form.Controls.Add($searchBox)

$searchButton = New-Object System.Windows.Forms.Button
$searchButton.Location = New-Object System.Drawing.Point(380, 10)
$searchButton.Text = "Search"
$searchButton.add_Click({
    $searchText = $searchBox.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($searchText)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a search term", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    $searchButton.Text = "Loading"
    SearchOrListApps -query $searchText
    $searchButton.Text = "Search"
})
$form.Controls.Add($searchButton)

# Add a "Search Installed" button
$searchInstalledButton = New-Object System.Windows.Forms.Button
$searchInstalledButton.Location = New-Object System.Drawing.Point(470, 10)
$searchInstalledButton.Width = 120
$searchInstalledButton.Text = "Search Installed"
$searchInstalledButton.add_Click({
    $searchText = $searchBox.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($searchText)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a search term", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    $searchInstalledButton.Text = "Loading"
    SearchOrListApps -query $searchText -isInstalled $true
    $searchInstalledButton.Text = "Search Installed"
})
$form.Controls.Add($searchInstalledButton)

# Add a list box for displaying search results
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 50)
$listBox.Width = 560
$listBox.Height = 200
$form.Controls.Add($listBox)

# Add a button to install the selected app
$installButton = New-Object System.Windows.Forms.Button
$installButton.Location = New-Object System.Drawing.Point(10, 260)
$installButton.Text = "Install"
$installButton.add_Click({
    $selected = $listBox.SelectedItem
    if ($selected) {
        $installButton.Text = "Loading"
        try {
            winget install $selected
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
        $installButton.Text = "Install"
    }
})
$form.Controls.Add($installButton)

# Add a "List Installed" button
$listInstalledButton = New-Object System.Windows.Forms.Button
$listInstalledButton.Location = New-Object System.Drawing.Point(90, 260)
$listInstalledButton.Width = 105
$listInstalledButton.Text = "List Installed"
$listInstalledButton.add_Click({
    $listInstalledButton.Text = "Loading"
    $searchText = $searchBox.Text.Trim()
    SearchOrListApps -query $searchText -isInstalled $true
    $listInstalledButton.Text = "List Installed"
})
$form.Controls.Add($listInstalledButton)

# Add a button to uninstall the selected installed app
$uninstallButton = New-Object System.Windows.Forms.Button
$uninstallButton.Location = New-Object System.Drawing.Point(330, 260)
$uninstallButton.Text = "Uninstall"
$uninstallButton.add_Click({
    $selected = $listBox.SelectedItem
    if ($selected) {
        $uninstallButton.Text = "Loading"
        try {
            $installedApps = winget list
            if ($installedApps -contains $selected) {
                winget uninstall $selected
            } else {
                [System.Windows.Forms.MessageBox]::Show("Error: $selected is not installed", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
        $uninstallButton.Text = "Uninstall"
    }
})

# Clear the list of search results on initialization
$listBox.Items.Clear()

# Show the form
$form.ShowDialog() | Out-Null
