import std.stdio, std.process, std.net.curl;
import std.string;
static import std.file;
static import std.regex;
import std.conv;
import consoled;

/**
 * A function has a name and an array of lines.
 * The name is the full name of the function, i.e.
 *    std_askyesno
 */
struct func
{
  string   name;
  string[] lines;
}

/**
 * A module has an array of functions and a name.
 * The name is the part of the functions before the '_', i.e.
 *    std
 */
struct modl
{
  string       name;
  func[string] funcs;
}

/**
 *
 */
class Lib
{
  modl[string] modules;
  void bar()
  {
    writeln("bad bar");
  }
}

// All modules
func[string] flib;

// Absolute path to ~/.bit
string homepath;

string stdliburl = "https://raw.githubusercontent.com" ~
  "/tmlbl/bit/master/std.sh";

void main(string[] args)
{
  homepath = environment["HOME"] ~ "/.bit";
  // Exit if no file specified
  if (args.length < 2) {
    writeln("Please specify a source file");
    std.c.process.exit(1);
  }
  // Populate the flib
  buildIndex();

  if (args[1] == "list")
  {
    list();
  }

  // Read the input file lines
  auto lines = splitLines(cast(string) std.file.read(args[1]));
  interpolate(lines);
}

// Print information about flib and exit
void list()
{
  int padding = 5;
  int linelen = 0;
  foreach (fn; flib)
  {
    if (fn.name.length + padding > linelen)
    {
      linelen = to!int(fn.name.length + padding);
    }
  }
  string spaces(func fn)
  {
    string res;
    string name = fromStringz(toStringz(fn.name));
    auto numspaces = linelen - res.length;
    for (int i = 0; i < numspaces; i++)
    {
      res = res ~ " ";
    }
    //return to!string(res);
    return format("%s", res);
  }
  foreach (fn; flib)
  {
    writeln(fn.name, spaces(fn), fn.lines.length, " lines");
  }
  std.c.process.exit(0);
}

// Get all module files
// Create the JSON cache of all function objects
void buildIndex()
{
  foreground = Color.blue;
  writeln("Building index...");
  resetColors();
  // If the home folder doesn't exist, create it
  if (!std.file.exists(homepath))
  {
    std.file.mkdir(homepath);
  }
  // Get the standard lib if it's not there
  if (!std.file.exists(homepath ~ "/std.sh"))
  {
    char[] content = get(stdliburl);
    std.file.write(homepath ~ "/std.sh", content);
  }
  // Iterate through each file in ~/.bit
  foreach (string name; std.file.dirEntries(homepath, std.file.SpanMode.breadth))
  {
    // Get file contents and extract all functions
    auto lines = splitLines(cast(string) std.file.read(name));
    foreach (fn; getFuncs(lines))
    {
      flib[fn.name] = fn;
    }
  }
}

func[] getFuncs(string[] lines)
{
  func[] result;
  foreach (int i, string ln; lines)
  {
    long parens = indexOf(ln, "()");
    bool isFunc = false;
    // Find the functions!
    if (parens != -1)
    {
      isFunc = true;
    }
    if (isFunc)
    {
      ++result.length;
      result[result.length - 1] = extractf(i, lines);
    }
  }
  return result;
}

// Create a bash function instance given a starting index and lines array
func extractf(int ix, string[] lines)
{
  auto name = chomp(std.regex.matchFirst(lines[ix], r"\S*\(\)")[0], "()");
  name = removechars(name, " ".dup);
  long start = ix;
  long end = 0;
  int block_depth = 0;
  string[] flines;

  for (long i = ix; end == 0; i++)
  {
    if (block_depth > 0)
    {
      flines.length++;
      flines[flines.length - 1] = lines[i];
    }
    foreach (ch; lines[i])
    {
      // Determine the end of the function block
      if (ch == '{')
      {
        block_depth++;
      }
      if (ch == '}')
      {
        block_depth--;
        if (block_depth == 0)
        {
          end = i;
        }
      }
    }
  }
  return *new func(name, flines);
}

void interpolate(string[] lines)
{

}
