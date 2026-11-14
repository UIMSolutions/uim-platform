/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Presentation layer (driving adapters).
module uim.platform.application_studio.presentation;

public {
  import uim.platform.application_studio.presentation.resources;
  import uim.platform.application_studio.presentation.tabular;
  import uim.platform.application_studio.presentation.http;
  import uim.platform.application_studio.presentation.odata;
  import uim.platform.application_studio.presentation.cli;
  import uim.platform.application_studio.presentation.web;
  // GtkD GUI: imported explicitly by source/gui.d (only built with --config=gui)
}
