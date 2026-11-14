/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving adapters. All of them go through one ODataEngine built from one
/// EDM model (presentation.odata), so the JSON API, vibe.d REST, OData v4,
/// the Diet dashboard, CLI and GUI share validation, scopes, query options
/// and error semantics.
module uim.platform.authorization.presentation;

public {
  import uim.platform.authorization.presentation.odata;
  import uim.platform.authorization.presentation.http;
  import uim.platform.authorization.presentation.rest;
  import uim.platform.authorization.presentation.web;
  import uim.platform.authorization.presentation.cli;
  // GtkD GUI: imported explicitly by source/gui.d (built with --config=gui only)
}
