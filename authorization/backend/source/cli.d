/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-authorization-cli seed
///   ./build/uim-authorization-cli list Policies --filter="kind eq 'custom'"
///   ./build/uim-authorization-cli check alice incident-management Incident Read --attributes=country=US
module cli;

import uim.platform.authorization;

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
    AuthorizationContainer container;
    try {
      auto config = loadAuthorizationConfig(cliOverrides(pre), pre.opt("config-dir", "config"));
      configureLogging("warn"); // keep stdout clean for scripting
      container = new AuthorizationContainer(config);
    } catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildAuthorizationCli(container).run(argv[1 .. $]);
  }
}
