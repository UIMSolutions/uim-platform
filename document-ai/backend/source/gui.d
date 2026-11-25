/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// GtkD desktop GUI entry point.
///
///   dub run --config=gui -- [--tenant=<id>] [--data-file=<path>] [--refresh=<seconds>]
module gui;

import uim.platform.document_ai;
import uim.platform.document_ai.presentation.gui;

version (unittest) {
} else {
  int main(string[] argv) {
    auto a = CliArgs.parse(argv[1 .. $]);
    Json[string] o = cliOverrides(a);
    o["workerIntervalSeconds"] = 0; // uploads in the GUI are extracted inline
    auto config = loadDaiConfig(o, a.opt("config-dir", "config"));
    auto container = new DaiContainer(config);
    container.events.log = false;
    auto tenant = a.opt("tenant", config.defaultTenant);
    auto refresh = cast(uint) a.intOpt("refresh", config.storage == "file" ? 5 : 0);
    return runDaiGui(container, tenant, a.opt("user", "gui"), argv[0 .. 1], refresh);
  }
}
