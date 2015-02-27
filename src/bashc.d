import std.stdio, std.c.process, std.process;
import std.file, std.string, std.regex;


struct func
{
  string   name;
  string[] lines;
  long     startIndex;
  long     endIndex;
}

void main(string[] args)
{
  // Exit if no file specified
  if (args.length < 2) {
    writeln("No source file specified");
    exit(1);
  }

  buildIndex();

  // Get file contents split into lines
  auto lines = splitLines(cast(string) read(args[1]));
  foreach (ln; lines) {
    long parens = indexOf(ln, "()");
    bool isFunc = false;
    // Find the functions!
    if (parens != -1) {
      isFunc = true;
    }
    if (isFunc) {
      auto foo = extractf(ln, lines);
      writeln(foo);
    }
  }
}

// Get all module files
// Create the JSON cache of all function objects
void buildIndex()
{
  writeln("Building index...");
  string homepath = environment["HOME"] ~ "/.bit";
  // If the home folder doesn't exist, create it
  if (!exists(homepath))
  {
    mkdir(homepath);
  }
}

// Create a bash function instance given a starting line
func extractf(string ln, string[] lines)
{
  auto name = chomp(matchFirst(ln, r"\S*\(\)")[0], "()");
  long start = 0;
  long end = 0;
  string[] flines;
  foreach (int i, string c; lines) {
    // Locate the function declaration
    if (indexOf(c, ln) != -1) {
      start = i;
    }
    // Grab every line before the closing brace
    if (start != 0 && end == 0) {
      flines.length++;
      flines[flines.length - 1] = c;
      if (indexOf(c, "}") != -1) {
        end = i;
      }
    }
  }
  return *new func(name, flines, start, end);
}
