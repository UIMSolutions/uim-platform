/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// GtkD (GTK 3) desktop adapter: the model driven entity browser of
/// uim-platform:service on top of the event mesh engine — a page per entity
/// set ($filter/$search, create/edit/delete forms generated from the EDM
/// types), the Statistics sheet and a runner for PublishEvent,
/// ConsumeMessages, PurgeQueue and DeliverWebhook. Only compiled with
/// --config=gui (version Have_gtk_d).
module uim.platform.events.presentation.gui;

version (Have_gtk_d) {
  public import uim.platform.service.presentation.gui;
  import uim.platform.events;

  /// Run the GUI main loop (blocks). autoRefreshSeconds > 0 reloads the
  /// current page periodically (useful with a file store shared with the server).
  int runEventsGui(EventsContainer container, string tenant, string user, string[] gtkArgs, uint autoRefreshSeconds = 0) {
    return runEntityBrowser(container.engine, tenant, user, gtkArgs, autoRefreshSeconds);
  }
}
