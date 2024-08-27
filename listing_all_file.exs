# List all file in index.md, ignore the .git folder or ohter hidden file or folder
# loop the folder and give the name of pattern directory_name(if has embed directory)/file_name
# for rollback first git add . and git commit
# overwrite to the index.md and give the rollack command of git

defmodule ListFiles do
  @moduledoc """
  A module that lists files and directories in a given path and writes the result to an index.md file.
  """

  @doc """
  Main entry point for the script.

  ## Parameters

    - args: List of command-line arguments

  ## Examples

      ListFiles.main([])
      ListFiles.main(["/path/to/directory"])
      ListFiles.main(["-h"])

  """
  def main(args) do
    case args do
      ["-h"] -> print_help()
      [folder_path] -> list_and_write_files(expand_path(folder_path))
      [] -> list_and_write_files(File.cwd!())
      _ -> IO.puts("Unknown arguments. Use -h for help.")
    end
  end

  @doc """
  Prints the help message to the console.
  """
  defp print_help do
    IO.puts """
    Usage: elixir listing_all_file.exs [FOLDER_PATH]

    This script lists all files and folders in the specified directory
    (ignoring .git and hidden files) and writes the result to an index.md
    file in that directory.

    Arguments:
      [FOLDER_PATH]    Path to the folder to process (optional, defaults to current directory)

    Options:
      -h               Show this help message
    """
  end

  @doc """
  Lists files and writes the content to index.md in the specified folder.

  ## Parameters

    - folder_path: Path to the folder to process

  """
  defp list_and_write_files(folder_path) do
    absolute_path = Path.expand(folder_path)
    content = generate_content(absolute_path)
    index_path = Path.join(absolute_path, "index.md")
    File.write!(index_path, content)

    IO.puts "File list has been written to #{index_path}"
    IO.puts "Rollback command: git reset HEAD^ && git checkout -- #{index_path}"
  end

  @doc """
  Generates the content for the index.md file.

  ## Parameters

    - folder_path: Path to the folder to process

  ## Returns

    A string containing the formatted content for index.md
  """
  defp generate_content(folder_path) do
    files_and_dirs = list_files_and_dirs(folder_path, 2)

    # Group files by directory
    grouped_files = 
      Enum.group_by(files_and_dirs, fn {dir, _, _} -> dir end)

    # Generate content for each directory
    Enum.map(grouped_files, fn {dir, entries} ->
      level = 2  # Adjust the level as needed
      dir_title = if dir == "." do
        "# All Files"
      else
        String.duplicate("#", level) <> " #{dir}"
      end

      # Collect all files for this directory
      file_links = Enum.flat_map(entries, fn {_, files, _} -> 
        Enum.map(files, fn file ->
          title = extract_title(Path.join(dir, file))
          "[#{title}](./#{file})"
        end)
      end)

      [dir_title | file_links] |> Enum.join("\n\n")
    end)
    |> Enum.join("\n\n")
  end

  @doc """
  Lists files and directories in the specified path, recursively.

  ## Parameters

    - path: Path to the directory to process
    - level: Current recursion level

  ## Returns

    A list of tuples containing directory names, lists of file names, and recursion levels
  """
  defp list_files_and_dirs(path, level) do
    path
    |> File.ls!()
    |> Enum.reject(&(String.starts_with?(&1, ".")))
    |> Enum.reduce({[], MapSet.new()}, fn item, {acc, seen} ->
      full_path = Path.join(path, item)
      if File.dir?(full_path) do
        # Check if the directory has already been seen
        unless MapSet.member?(seen, item) do
          # Include the directory in the result
          sub_files_and_dirs = list_files_and_dirs(full_path, level + 1)
          {acc ++ [{item, list_files(full_path), level}] ++ elem(sub_files_and_dirs, 0), MapSet.put(seen, item)}
        else
          {acc, seen}
        end
      else
        # Include files in the result
        {acc ++ [{Path.basename(path), [item], level}], seen}  # Include files in the result
      end
    end)
    |> elem(0)
  end

  @doc """
  Lists files in the specified path.

  ## Parameters

    - path: Path to the directory to process

  ## Returns

    A list of file names
  """
  defp list_files(path) do
    path
    |> File.ls!()
    |> Enum.reject(&(String.starts_with?(&1, ".")))
    |> Enum.filter(&(!File.dir?(Path.join(path, &1))))
  end

  @doc """
  Extracts the title from a file path.

  ## Parameters

    - file_path: Path to the file

  ## Returns

    The title of the file, or the file name if no title is found
  """
  defp extract_title(file_path) do
    if String.ends_with?(file_path, ".md") do
      case File.read(file_path) do
        {:ok, content} ->
          case Regex.run(~r/^#\s*(.+)$/m, content) do
            [_, title] -> String.trim(title)
            nil -> Path.basename(file_path, ".md")
          end
        {:error, _} -> Path.basename(file_path, ".md")
      end
    else
      Path.basename(file_path)
    end
  end

  @doc """
  Expands a given path to its absolute form.

  ## Parameters

    - path: The path to expand

  ## Returns

    The absolute path as a string
  """
  defp expand_path(path) do
    Path.expand(path)
  end
end

ListFiles.main(System.argv())
