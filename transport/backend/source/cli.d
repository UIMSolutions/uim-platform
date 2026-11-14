/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- demo
///   ./build/uim-transport-cli queue import QA --json
module cli;

import std.stdio : stdout;
import uim.platform.transport;

version (unittest) {
} else {
  int main(string[] argv) {
    auto config = loadConfig();
    // CLI-only overrides (highest priority)
    auto a = CliArgs.parse(argv[1 .. $]);
    if (a.has("data-dir"))
      config.dataDir = a.opt("data-dir");
    if (a.has("storage"))
      config.storage = a.opt("storage");
    configureLogging(a.has("verbose") ? "debug" : "warn");

    auto container = buildContainer(config);
    auto cli = new TransportCli(container.ports, config, (string s) @trusted { stdout.write(s); });
    return cli.run(argv[1 .. $]);
  }
}
