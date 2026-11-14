/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-event-mesh-cli seed --data-file=data/event-mesh.json
///   ./build/uim-event-mesh-cli list Queues --filter="status eq 'active'"
///   ./build/uim-event-mesh-cli publish acme/sales/orders/ce/created '{"orderId":"1"}' --service=sales-orders
module cli;

import uim.platform.events;

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
    EventsContainer container;
    try
      container = new EventsContainer(loadEventsConfig(cliOverrides(pre), pre.opt("config-dir", "config")));
    catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildEventsCli(container).run(argv[1 .. $]);
  }
}
