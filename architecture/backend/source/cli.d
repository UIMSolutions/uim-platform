/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-architecture-cli seed --data-file=data/architecture.json
///   ./build/uim-architecture-cli list BuildingBlocks --filter="kind eq 'solution'"
///   ./build/uim-architecture-cli impact tbb-postgres
module cli;

import uim.platform.architecture;

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
    ArchitectureContainer container;
    try {
      auto overrides = cliOverrides(pre);
      overrides["seedDemoData"] = false;
      container = new ArchitectureContainer(loadArchitectureConfig(overrides, pre.opt("config-dir", "config")));
      container.events.log = false;
    } catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildArchitectureCli(container).run(argv[1 .. $]);
  }
}
