/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-application-events-cli seed --data-file=data/application-events.json
///   ./build/uim-application-events-cli publish sap.s4.beh.salesorder.v1.SalesOrder.Created.v1 s4 '{"salesOrder":"1"}'
///   ./build/uim-application-events-cli dead-letters
///   ./build/uim-application-events-cli list Subscriptions --filter="health eq 'error'"
module cli;

import uim.platform.application_events;

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
    AehContainer container;
    try {
      Json[string] o = cliOverrides(pre);
      container = new AehContainer(loadAehConfig(o, pre.opt("config-dir", "config")));
      container.audit.log = false;
    } catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildAehCli(container).run(argv[1 .. $]);
  }
}
