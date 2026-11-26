/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-application-autoscaler-cli seed --data-file=data/application-autoscaler.json
///   ./build/uim-application-autoscaler-cli simulate order-service cpu 95 --seconds=240
///   ./build/uim-application-autoscaler-cli evaluate order-service
///   ./build/uim-application-autoscaler-cli list Bindings --filter="autoscaled eq true"
module cli;

import uim.platform.application_autoscaler;

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
    AasContainer container;
    try {
      Json[string] o = cliOverrides(pre);
      container = new AasContainer(loadAasConfig(o, pre.opt("config-dir", "config")));
      container.events.log = false;
    } catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildAasCli(container).run(argv[1 .. $]);
  }
}
