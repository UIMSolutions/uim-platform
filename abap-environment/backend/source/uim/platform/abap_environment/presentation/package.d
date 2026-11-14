/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Presentation layer (driving adapters).
module uim.platform.abap_environment.presentation;

public {
  import uim.platform.abap_environment.presentation.resources;
  import uim.platform.abap_environment.presentation.tabular;
  import uim.platform.abap_environment.presentation.http;
  import uim.platform.abap_environment.presentation.odata;
  import uim.platform.abap_environment.presentation.cli;
  import uim.platform.abap_environment.presentation.web;
  // GtkD GUI: imported explicitly by source/gui.d (only built with --config=gui)
}
