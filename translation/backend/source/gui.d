/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// GtkD desktop GUI entry point.
///
///   dub run --config=gui -- [--tenant=<id>] [--data-dir=<dir>]
module gui;

import uim.platform.translation;
import uim.platform.translation.presentation.gui;

version (unittest) {
} else {
  int main(string[] argv) {
    auto config = loadConfig();
    configureLogging("warn");
    auto a = CliArgs.parse(argv[1 .. $]);
    if (a.has("data-dir"))
      config.dataDir = a.opt("data-dir");
    if (a.has("storage"))
      config.storage = a.opt("storage");
    auto tenant = a.opt("tenant", config.defaultTenant);

    auto container = buildContainer(config);
    return runTranslationGui(new ResourceRegistry(container.ports), config, tenant, argv[0 .. 1]);
  }
}
