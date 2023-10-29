# Startup Manager

This PowerShell script manages startup commands for your Windows system. It provides a text-based interface to view, add, update, and delete startup commands.

## Usage

1. **View Startup Commands**
    - Run the script. It will display a list of startup commands currently configured on your system.

2. **Navigation**
    - Use the `Up` and `Down` arrow keys to navigate through the list.
    - Press `Enter` to view details of the selected startup command.

3. **View Command Details**
    - Upon pressing `Enter`, it will display the name and execution path of the selected startup command.

4. **Add a New Startup Command**
    - Press `A` to add a new startup command.
    - Enter the name and execution path as prompted.

5. **Update a Startup Command**
    - Use the `W` key to update the selected startup command.
    - Enter the new name and execution path when prompted.

6. **Delete a Startup Command**
    - Press `Del` to delete the selected startup command.
    - Confirmation will be requested. Type `y` to confirm or `n` to cancel.

7. **Refresh List**
    - Press `F5` or `R` to refresh the list of startup commands.

8. **Exit the Program**
    - Press `Esc` to exit the script.

## Caution
- Deleting a startup command is irreversible. Be careful when prompted for deletion.

## Notes
- The script accesses and manipulates the Windows registry to manage startup commands.

## Script Behavior
- The script will present a text-based user interface, allowing interaction through keyboard commands.

## Requirements
- Windows PowerShell environment.
