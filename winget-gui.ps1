# Create a new PowerShell GUI window
Add-Type -AssemblyName System.Windows.Forms
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
    # Search for the specified app and display the results in a list box
    $searchButton.Text = "Loading"
    $results = winget search $searchBox.Text | Select-Object -Skip 2
    $listBox.Items.Clear()
    foreach ($result in $results) {
        $listBox.Items.Add($result)
    }
    $searchButton.Text = "Search"
})
$form.Controls.Add($searchButton)

$searchInstalledButton = New-Object System.Windows.Forms.Button
$searchInstalledButton.Location = New-Object System.Drawing.Point(470, 10)
$searchInstalledButton.Width = 120
$searchInstalledButton.Text = "Search Installed"
$searchInstalledButton.add_Click({
    # Search for an installed app and display the results in a list box
    $searchInstalledButton.Text = "Loading"
    $results = winget list $searchBox.Text | Select-Object -Skip 2
    $listBox.Items.Clear()
    foreach ($result in $results) {
        $listBox.Items.Add($result)
    }
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
    # Install the selected app
    $selected = $listBox.SelectedItem
    if ($selected) {
        $installButton.Text = "Loading"
        winget install $selected
        $installButton.Text = "Install"
    }
})
$form.Controls.Add($installButton)

# Add a button to list all installed apps
$listInstalledButton = New-Object System.Windows.Forms.Button
$listInstalledButton.Location = New-Object System.Drawing.Point(90, 260)
$listInstalledButton.Width = 105
$listInstalledButton.Text = "List Installed"
$listInstalledButton.add_Click({
    # List all installed apps and display the results in a list box
    $listInstalledButton.Text = "Loading"
    $results = winget list | Select-Object -Skip 2
    $listBox.Items.Clear()
    foreach ($result in $results) {
        $listBox.Items.Add($result)
    }
    $listInstalledButton.Text = "List Installed"
})
$form.Controls.Add($listInstalledButton)

# Add a button to uninstall the selected installed app
$uninstallButton = New-Object System.Windows.Forms.Button
$uninstallButton.Location = New-Object System.Drawing.Point(330, 260)
$uninstallButton.Text = "Uninstall"
$uninstallButton.add_Click({
    # Uninstall the selected installed app
    $selected = $listBox.SelectedItem
    if ($selected) {
        $uninstallButton.Text = "Loading"
        winget uninstall $selected
        $uninstallButton.Text = "Uninstall"
    }
})
$form.Controls.Add($uninstallButton)

# Show the form
$form.ShowDialog() | Out-Null
