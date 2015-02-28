import std.stdio, std.process, std.net.curl;
import std.string;
static import std.file;
static import std.regex;

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
    writeln("Please specify a source file");
    std.c.process.exit(1);
  }
  // Populate the ftable
  buildIndex();
  foreach (f; ftable)
  {
    writeln(f.name, "  lines: ", f.lines.length);
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

  for (long i = ix; i < lines.length; i++)
  {
    if (block_depth > 0 && end == 0)
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
