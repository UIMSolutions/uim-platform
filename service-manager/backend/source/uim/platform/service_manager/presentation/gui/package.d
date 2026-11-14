/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// GtkD (GTK 3) desktop adapter: the model driven entity browser of
/// uim-platform:service on top of the service manager engine — a page per
/// entity set ($filter/$search, create/edit/delete forms generated from the
/// EDM types), the Statistics sheet and a runner for SyncBrokerCatalog and
/// CompleteOperation. Only compiled with --config=gui (version Have_gtk_d).
module uim.platform.service_manager.presentation.gui;

version (Have_gtk_d) {
  public import uim.platform.service.presentation.gui;
  import uim.platform.service_manager;

  /// Run the GUI main loop (blocks). autoRefreshSeconds > 0 reloads the
  /// current page periodically (useful with a file store shared with the server).
  int runServiceManagerGui(ServiceManagerContainer container, string tenant, string user, string[] gtkArgs,
    uint autoRefreshSeconds = 0) {
    return runEntityBrowser(container.engine, tenant, user, gtkArgs, autoRefreshSeconds);
  }
}
