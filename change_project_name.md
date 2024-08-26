# Automating Project Renaming in Elixir

![Elixir Code on Computer Screen](https://images.unsplash.com/photo-1517694712202-14dd9538aa97?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80)

When working on Elixir projects, you might occasionally need to rename your project. This process can be tedious and error-prone if done manually. To simplify this task, I've created a handy Elixir script that automates the project renaming process.

## The Change Project Name Script

This Elixir script, `change_project_name.exs`, recursively traverses your project directory, renaming files and directories, and updating file contents to reflect the new project name. It's designed to handle various cases (uppercase, lowercase, and camelcase) to maintain the original formatting.

You can find the full implementation of the script [here](https://github.com/ConsonHayashi/work_space/blob/main/change_project_name.exs).

### Key Features

1. **Recursive Directory Processing**: The script walks through all subdirectories of your project.
2. **Case-Sensitive Renaming**: It preserves the original casing of the project name in files and directories.
3. **Content Updating**: File contents are updated to reflect the new project name.
4. **User-Friendly**: Includes a help message and clear usage instructions.

### How to Use

1. Save the script as `change_project_name.exs` in your project directory.
2. Run the script with the following command:

   ```bash
   elixir change_project_name.exs <new_project_name> <old_project_name>
   ```

   For example:
   ```bash
   elixir change_project_name.exs new_awesome_project old_project_name
   ```

3. The script will process all files and directories, renaming and updating content as necessary.

## Behind the Scenes

The script uses several Elixir features and techniques:

- **Pattern Matching**: To handle different command-line arguments.
- **File System Operations**: `File.ls!/1`, `File.dir?/1`, `File.rename!/2`, etc.
- **Regular Expressions**: To find and replace the project name in various contexts.
- **String Manipulation**: Functions like `String.replace/3` and `Macro.camelize/1`.

## Considerations

While this script is a powerful tool for renaming projects, always remember to:

1. **Backup Your Project**: Before running the script, make sure you have a backup of your entire project.
2. **Version Control**: If using Git, commit all changes before running the script, so you can easily revert if needed.
3. **Review Changes**: After running the script, review the changes to ensure everything was updated correctly.

## Conclusion

Automating the project renaming process can save time and reduce errors. This Elixir script provides a simple yet effective way to rename your Elixir projects. Feel free to adapt and improve the script to fit your specific needs!