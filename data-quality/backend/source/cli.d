/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-data-quality-cli seed --data-file=data/data-quality.json
///   ./build/uim-data-quality-cli list Violations --filter="severity eq 'critical'"
///   ./build/uim-data-quality-cli validate customers
module cli;

import uim.platform.data_quality;

version (unittest) {
} else {
  int main(string[] argv) {
    import std.stdio : stderr;

    CliArgs pre;
    try
      pre = CliArgs.parse(argv[1 .. $]);
    catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 2;
    }
    DqContainer container;
    try {
      Json[string] o = cliOverrides(pre);
      container = new DqContainer(loadDqConfig(o, pre.opt("config-dir", "config")));
      container.events.log = false;
    } catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildDqCli(container).run(argv[1 .. $]);
  }
}
