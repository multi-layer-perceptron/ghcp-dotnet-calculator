# Get the contents of the current folder
Get-ChildItem -Path . -Recurse | ForEach-Object {
    # Output the full path of each item
    $_.FullName
}
