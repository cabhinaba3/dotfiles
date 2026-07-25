# Broot Shortcuts & Cheatsheet

Broot provides a tree-like view of your directories that you can instantly fuzzy-search.

## Basic Navigation
- **`↓` / `↑`** or **`Tab` / `Shift+Tab`**: Move selection down/up.
- **`Enter`**: Open a file (in your default `$EDITOR`) or expand a directory.
- **`Esc`**: Clear current search/filter. If search is empty, go up one level.
- **`?`**: Open the built-in help screen (lists all shortcuts).

## Searching and Filtering
Just start typing to filter the tree!
- **`abc`**: Fuzzy search for files/directories containing "abc".
- **`!abc`**: Show only files/directories NOT containing "abc".
- **`/pattern`**: Use regular expressions to search.

## Commands (Verbs)
Type a space or `:` after your search query to start a command.
- **`:cd`**: Change directory to the selected one (requires `br` shell function).
- **`:rm`**: Delete the selected file.
- **`:mv <new_path>`**: Rename or move the file.
- **`:cp <new_path>`**: Copy the file.
- **`:mkdir <name>`**: Create a new directory.

## Display Toggles
- **`Alt+h`** (or `:h`): Toggle visibility of **hidden** files.
- **`Alt+i`** (or `:gi`): Toggle **`.gitignore`** rules (show/hide gitignored files).
- **`Alt+s`** (or `:s`): Toggle **sizes** (calculates total size of folders).
- **`Alt+p`** (or `:p`): Toggle **permissions** display.
- **`Alt+d`** (or `:d`): Toggle file modification **dates**.

## Quitting & Changing Directories
To use broot to change your terminal's directory, you **must** use the `br` wrapper instead of typing `broot`. 
- **`br`**: Opens broot.
- **`Alt+Enter`** (on a directory): Quits broot and instantly `cd`s your terminal into that directory!
