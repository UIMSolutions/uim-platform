/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-ai-launchpad-cli seed --data-file=data/ai-launchpad.json
///   ./build/uim-ai-launchpad-cli launchpad
///   ./build/uim-ai-launchpad-cli executions --status=running
///   ./build/uim-ai-launchpad-cli run-prompt summarize-ticket language=English "ticket=Printer is on fire"
///   ./build/uim-ai-launchpad-cli logs --severity=warning
module cli;

import uim.platform.ai_launchpad;

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
    AilpContainer container;
    try {
      Json[string] o = cliOverrides(pre);
      container = new AilpContainer(loadAilpConfig(o, pre.opt("config-dir", "config")));
      container.audit.log = false;
      container.bootstrapTenant(pre.opt("tenant", container.config.defaultTenant));
    } catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildAilpCli(container).run(argv[1 .. $]);
  }
}
