import std.stdio, std.process, std.net.curl;
import std.string, std.regex;
static import std.file;


struct func
{
  string   name;
  string[] lines;
  long     startIndex;
  long     endIndex;
}

func[string] ftable;

string stdliburl = "https://raw.githubusercontent.com/tmlbl/bit/master/std.sh";

void main(string[] args)
{
  // Exit if no file specified
  if (args.length < 2) {
    throw new Exception("No source file specified");
  }

  buildIndex();
  writeln(ftable);

  // Get file contents split into lines
  auto lines = splitLines(cast(string) std.file.read(args[1]));
  // Interpolate functions...
}

// Get all module files
// Create the JSON cache of all function objects
void buildIndex()
{
  writeln("Building index...");
  string homepath = environment["HOME"] ~ "/.bit";
  // If the home folder doesn't exist, create it
  if (!std.file.exists(homepath))
  {
    std.file.mkdir(homepath);
  }
  if (!std.file.exists(homepath ~ "/std.sh"))
  {
    char[] content = get(stdliburl);
    std.file.write(homepath ~ "/std.sh", content);
  }
  // Iterate through each file in ~/.bit
  foreach (string name; std.file.dirEntries(homepath, std.file.SpanMode.breadth))
  {
    // Get file contents and split into lines
    auto lines = splitLines(cast(string) std.file.read(name));
    foreach (fn; getFuncs(lines))
    {
      ftable[fn.name] = fn;
    }
  }
}

func[] getFuncs(string[] lines)
{
  func[] result;
  foreach (ln; lines)
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
      result[result.length - 1] = extractf(ln, lines);
    }
  }
  return result;
}

// Create a bash function instance given a starting line
func extractf(string ln, string[] lines)
{
  auto name = chomp(matchFirst(ln, r"\S*\(\)")[0], "()");
  long start = 0;
  long end = 0;
  string[] flines;
  foreach (int i, string c; lines)
  {
    // Locate the function declaration
    if (indexOf(c, ln) != -1)
    {
      start = i;
    }
    // Grab every line before the closing brace
    if (start != 0 && end == 0)
    {
      flines.length++;
      flines[flines.length - 1] = c;
      if (indexOf(c, "}") != -1)
      {
        end = i;
      }
    }
  }
  return *new func(name, flines, start, end);
}
