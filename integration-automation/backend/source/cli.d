/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-integration-automation-cli seed --data-file=data/integration-automation.json
///   ./build/uim-integration-automation-cli list Workflows --filter="status eq 'inProgress'"
///   ./build/uim-integration-automation-cli tasks wf-employee-wave1
module cli;

import uim.platform.integration_automation;

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
    IaContainer container;
    try {
      Json[string] o = cliOverrides(pre);
      container = new IaContainer(loadIaConfig(o, pre.opt("config-dir", "config")));
      container.events.log = false;
    } catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildIaCli(container).run(argv[1 .. $]);
  }
}
