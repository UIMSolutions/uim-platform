/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Presentation layer (driving adapters).
module uim.platform.object_store.presentation;

public {
  import uim.platform.object_store.presentation.resources;
  import uim.platform.object_store.presentation.http;
  import uim.platform.object_store.presentation.odata;
  import uim.platform.object_store.presentation.cli;
  import uim.platform.object_store.presentation.web;
  import uim.platform.object_store.presentation.tabular;
  // GtkD GUI: imported explicitly by source/gui.d (only built with --config=gui)
}
