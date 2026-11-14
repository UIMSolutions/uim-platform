/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-service-manager-cli seed
///   ./build/uim-service-manager-cli list ServiceInstances --filter="status eq 'created'"
module cli;

import uim.platform.service_manager;

version (unittest) {
} else {
  int main(string[] argv) {
    CliArgs pre;
    try
      pre = CliArgs.parse(argv[1 .. $]);
    catch (Exception e) {
      import std.stdio : stderr;

      stderr.writeln("error: ", e.msg);
      return 2;
    }
    ServiceManagerContainer container;
    try
      container = new ServiceManagerContainer(loadServiceManagerConfig(cliOverrides(pre), pre.opt("config-dir", "config")));
    catch (Exception e) {
      import std.stdio : stderr;

      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildServiceManagerCli(container).run(argv[1 .. $]);
  }
}
