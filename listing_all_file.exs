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
  def print_help do
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
  def list_and_write_files(folder_path) do
    absolute_path = Path.expand(folder_path)
    relative_path = Path.relative_to(absolute_path, File.cwd!())
    content = generate_content(absolute_path, relative_path)
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
  def generate_content(folder_path, relative_path) do
    files_and_dirs = list_files_and_dirs(folder_path, 2, relative_path)

    # IO.inspect(files_and_dirs, label: "files_and_dirs")

    index_content = Enum.map(files_and_dirs, fn {dir, files, level} ->
      dir_title = String.duplicate("#", level) <> " #{dir}"
      file_links = Enum.map(files, fn file ->
        title = extract_title(Path.join(dir, file))
        "[#{title}](#{dir}/#{file})"
      end)
      [dir_title | file_links] |> Enum.join("\n\n")
    end)
    |> Enum.join("\n\n")

    "# All File \n\n" <> index_content
  end

  @doc """
  Lists files and directories in the specified path, recursively.

  ## Parameters

    - path: Path to the directory to process
    - level: Current recursion level
    - base_path: Base path for relative path calculation (optional)

  ## Returns

    A list of tuples containing directory names, lists of file names, and recursion levels
  """
  def list_files_and_dirs(path, level, base_path \\ nil) do

    path
    |> File.ls!()
    |> Enum.reject(&(String.starts_with?(&1, ".")))
    |> Enum.reduce([], fn item, acc ->
      full_path = Path.join(path, item)
      if File.dir?(full_path) do
        relative_path = Path.join(base_path, item)
        sub_files_and_dirs = list_files_and_dirs(full_path, level + 1, relative_path)
        [{relative_path, list_files(full_path), level} | sub_files_and_dirs] ++ acc
      else
        acc
      end
    end)
  end

  @doc """
  Lists files in the specified path.

  ## Parameters

    - path: Path to the directory to process

  ## Returns

    A list of file names
  """
  def list_files(path) do
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
  def extract_title(file_path) do
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
  def expand_path(path) do
    Path.expand(path)
  end
end

ListFiles.main(System.argv())
