/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Minimal, dependency-free command line parser:
///   positional arguments, --key=value, --key value and boolean --flag.
module uim.platform.agentry.presentation.cli.args;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Options that never take a value (so "--json list" keeps "list" positional).
enum string[] cliFlags = ["json", "help", "yes", "mandatory", "managed", "offline", "push", "ssl"];

struct CliArgs {
  string[] positional;
  string[string] options;

  /// Parse argv WITHOUT the program name.
  static CliArgs parse(const string[] argv) {
    CliArgs a;
    for (size_t i = 0; i < argv.length; i++) {
      auto arg = argv[i];
      if (arg == "--") {
        a.positional ~= argv[i + 1 .. $].dup;
        break;
      }
      if (arg.startsWith("--") && arg.length > 2) {
        auto body = arg[2 .. $];
        auto eq = body.indexOf('=');
        if (eq >= 0) {
          a.options[body[0 .. eq]] = body[eq + 1 .. $];
        } else if (cliFlags.canFind(body) || i + 1 >= argv.length || argv[i + 1].startsWith("--")) {
          a.options[body] = "true";
        } else {
          a.options[body] = argv[++i];
        }
      } else if (arg == "-h") {
        a.options["help"] = "true";
      } else {
        a.positional ~= arg;
      }
    }
    return a;
  }

  bool has(string key) const {
    return (key in options) !is null;
  }

  string opt(string key, string fallback = "") const {
    if (auto v = key in options)
      return *v;
    return fallback;
  }

  bool flag(string key) const {
    auto v = opt(key, "false").toLower;
    return v == "true" || v == "1" || v == "yes";
  }

  int intOpt(string key, int fallback) const {
    auto v = opt(key);
    if (v.length == 0)
      return fallback;
    try
      return v.to!int;
    catch (Exception)
      throw new CliUsageError("--" ~ key ~ " expects a number, got '" ~ v ~ "'");
  }

  /// Comma separated list option.
  string[] listOpt(string key) const {
    return opt(key).split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
  }

  /// Positional argument i ("" if missing).
  string arg(size_t i) const {
    return i < positional.length ? positional[i] : "";
  }

  /// Positional argument i, or a usage error.
  string requireArg(size_t i, string what) const {
    auto v = arg(i);
    if (v.length == 0)
      throw new CliUsageError("missing argument: " ~ what);
    return v;
  }

  string requireOpt(string key) const {
    auto v = opt(key);
    if (v.length == 0)
      throw new CliUsageError("missing option: --" ~ key);
    return v;
  }
}

/// Wrong command line usage (exit code 2).
class CliUsageError : Exception {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}

///
unittest {
  mixin(ShowTest!("CliArgs"));

  auto a = CliArgs.parse(["devices", "list", "--tenant", "t1", "--limit=5", "--json", "--categories=dataAccess, configuration"]);
  assert(a.positional == ["devices", "list"]);
  assert(a.opt("tenant") == "t1");
  assert(a.intOpt("limit", 0) == 5);
  assert(a.flag("json"));
  assert(a.listOpt("categories") == ["dataAccess", "configuration"]);
  assert(a.arg(5) == "");

  auto b = CliArgs.parse(["--json", "stats"]);
  assert(b.flag("json") && b.positional == ["stats"]);
}
