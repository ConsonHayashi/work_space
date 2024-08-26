# change project name 

# Usage: elixir change_project_name.exs <new_project_name> <old_project_name>
# Example: elixir change_project_name.exs new_project_name old_project_name

## accept a new project name as parameter, anyway the old project name will be past as the second parameter
## The project name exists in the file name and the file content
## need to loop all files and replace the old name with the new name
## Notice the uppercase and lowercase and don't break the original case


defmodule ChangeProjectName do
  @moduledoc """
  A module to automate the process of renaming an Elixir project.

  This module provides functionality to recursively rename files, directories,
  and update file contents with a new project name while preserving the original case.

  ## Usage

      ChangeProjectName.run(System.argv())

  From the command line:

      elixir change_project_name.exs <new_project_name> <old_project_name>

  ## Examples

      $ elixir change_project_name.exs new_awesome_project old_project_name

  """

  @doc """
  Runs the project renaming process based on command-line arguments.

  ## Parameters

    - args: A list of command-line arguments.

  ## Returns

    Prints usage information or executes the renaming process.

  """
  def run(args)

  @doc """
  Changes the project name from old_name to new_name.

  This function initiates the recursive process of renaming files and directories,
  and updating file contents.

  ## Parameters

    - new_name: The new project name.
    - old_name: The current project name to be replaced.

  """
  defp change_project_name(new_name, old_name)

  @doc """
  Processes a directory recursively, renaming files and updating contents.

  ## Parameters

    - dir: The directory to process.
    - old_name: The current project name to be replaced.
    - new_name: The new project name.

  """
  defp process_directory(dir, old_name, new_name)

  @doc """
  Changes a directory name if it contains the old project name.

  ## Parameters

    - dir: The directory path to potentially rename.
    - old_name: The current project name to be replaced.
    - new_name: The new project name.

  ## Returns

    The new directory name (which may be unchanged if no renaming occurred).

  """
  defp change_directory_name(dir, old_name, new_name)

  @doc """
  Updates the content of a file, replacing occurrences of the old project name.

  ## Parameters

    - file: The file path to update.
    - old_name: The current project name to be replaced.
    - new_name: The new project name.

  """
  defp change_file_content(file, old_name, new_name)

  @doc """
  Renames a file if its name contains the old project name.

  ## Parameters

    - file: The file path to potentially rename.
    - old_name: The current project name to be replaced.
    - new_name: The new project name.

  """
  defp change_file_name(file, old_name, new_name)

  @doc """
  Replaces the old name with the new name while preserving the original case.

  ## Parameters

    - matched: The matched string to be replaced.
    - old_name: The current project name to be replaced.
    - new_name: The new project name.

  ## Returns

    The replaced string with preserved case.

  """
  defp case_replace(matched, old_name, new_name)

  defp print_usage do
    IO.puts """
    Usage: elixir change_project_name.exs <new_project_name> <old_project_name>
    Example: elixir change_project_name.exs new_project_name old_project_name

    Options:
      -h    Show this help message
    """
  end

  defp change_project_name(new_name, old_name) do
    process_directory(".", old_name, new_name)
    IO.puts("Project name changed from #{old_name} to #{new_name}")
  end

  defp process_directory(dir, old_name, new_name) do
    File.ls!(dir)
    |> Enum.each(fn item ->
      path = Path.join(dir, item)
      if File.dir?(path) do
        new_dir = change_directory_name(path, old_name, new_name)
        process_directory(new_dir, old_name, new_name)
      else
        change_file_content(path, old_name, new_name)
        change_file_name(path, old_name, new_name)
      end
    end)
    
    IO.puts("Project name changed from #{old_name} to #{new_name}")
  end

  defp change_directory_name(dir, old_name, new_name) do
    new_dir = String.replace(dir, ~r/#{Regex.escape(old_name)}/i, fn matched ->
      case_replace(matched, old_name, new_name)
    end)
    if dir != new_dir do
      File.rename!(dir, new_dir)
      IO.puts("Renamed directory: #{dir} -> #{new_dir}")
    end
    new_dir
  end

  defp change_file_content(file, old_name, new_name) do
    content = File.read!(file)
    new_content = String.replace(content, ~r/#{old_name}/i, fn matched ->
      case_replace(matched, old_name, new_name)
    end)
    if content != new_content, do: File.write!(file, new_content)
  end

  defp change_file_name(file, old_name, new_name) do
    new_file = String.replace(file, ~r/#{old_name}/i, fn matched ->
      case_replace(matched, old_name, new_name)
    end)
    if file != new_file, do: File.rename(file, new_file)
  end

  defp case_replace(matched, old_name, new_name) do
    cond do
      matched == String.upcase(old_name) -> String.upcase(new_name)
      matched == String.downcase(old_name) -> String.downcase(new_name)
      matched == Macro.camelize(old_name) -> Macro.camelize(new_name)
      true -> new_name
    end
  end
end

# Usage: elixir change_project_name.exs <new_project_name> <old_project_name>
# Example: elixir change_project_name.exs new_project_name old_project_name
ChangeProjectName.run(System.argv())