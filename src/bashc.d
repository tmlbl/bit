import std.stdio, std.process, std.net.curl;
import std.string;
static import std.file;


struct func
{
  string   name;
  string[] lines;
}

func[string] ftable;

string stdliburl = "https://raw.githubusercontent.com/tmlbl/bit/master/std.sh";
string homepath;

void main(string[] args)
{
  homepath = environment["HOME"] ~ "/.bit";
  // Exit if no file specified
  if (args.length < 2) {
    throw new Exception("No source file specified");
  }
  // Populate the ftable
  buildIndex();
  foreach (f; ftable)
  {
    writeln(f.name);
  }
  // Read the input file lines
  auto lines = splitLines(cast(string) std.file.read(args[1]));
}

unittest
{
  assert(true);
  // Should not be considered comments
  //"$#", ${#foo}, string="this # string",
  // string='that # string', ${foo#bar}, ${foo##baar},
}

// Get all module files
// Create the JSON cache of all function objects
void buildIndex()
{
  writeln("Building index...");
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
    // Get file contents and extract all functions
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
  auto name = chomp(std.regex.matchFirst(ln, r"\S*\(\)")[0], "()");
  name = removechars(name, " ".dup);
  long start = 0;
  long end = 0;
  int block_depth = 0;
  string[] flines;

  foreach (int i, string c; lines)
  {
    // Locate the function declaration
    if (indexOf(c, ln) != -1)
    {
      start = i;
    }
    // Grab every line before the function close
    if (start != 0 && end == 0)
    {
      flines.length++;
      flines[flines.length - 1] = c;
      // Determine the end of the function block
      if (indexOf(c, "{") != -1)
      {
        block_depth++;
      }
      if (indexOf(c, "}") != -1)
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
