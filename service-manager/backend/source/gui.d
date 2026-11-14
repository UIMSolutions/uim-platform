/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// GtkD desktop GUI entry point.
///
///   dub run --config=gui -- [--tenant=<id>] [--data-file=<path>] [--refresh=<seconds>]
module gui;

import uim.platform.service_manager;
import uim.platform.service_manager.presentation.gui;

version (unittest) {
} else {
  int main(string[] argv) {
    auto a = CliArgs.parse(argv[1 .. $]);
    auto config = loadServiceManagerConfig(cliOverrides(a), a.opt("config-dir", "config"));
    auto container = new ServiceManagerContainer(config);
    auto tenant = a.opt("tenant", config.defaultTenant);
    auto refresh = cast(uint) a.intOpt("refresh", config.storage == "file" ? 10 : 0);
    return runServiceManagerGui(container, tenant, a.opt("user", "gui"), argv[0 .. 1], refresh);
  }
}
