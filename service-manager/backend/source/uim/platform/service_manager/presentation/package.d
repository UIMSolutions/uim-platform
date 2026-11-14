/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving adapters. All of them go through one ODataEngine built from one
/// EDM model (presentation.odata), so REST, OData v4, CLI and GUI share
/// validation, scopes, query options and error semantics.
module uim.platform.service_manager.presentation;

public {
  import uim.platform.service_manager.presentation.odata;
  import uim.platform.service_manager.presentation.http;
  import uim.platform.service_manager.presentation.cli;
  import uim.platform.service_manager.presentation.web;
  // GtkD GUI: imported explicitly by source/gui.d (built with --config=gui only)
}
