/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving adapters. The management adapters (OData v4, REST, CLI, GUI) go
/// through one ODataEngine built from one EDM model (presentation.odata), so
/// they share validation, scopes, query options and error semantics. The
/// OAuth 2.0 protocol endpoints (presentation.http.controllers.protocol) call
/// the protocol ports directly.
module uim.platform.oauth.presentation;

public {
  import uim.platform.oauth.presentation.cli;
  import uim.platform.oauth.presentation.http;
  import uim.platform.oauth.presentation.odata;
  import uim.platform.oauth.presentation.rest;
  import uim.platform.oauth.presentation.unix;
  import uim.platform.oauth.presentation.web;
  // GtkD GUI: imported explicitly by source/gui.d (built with --config=gui only)
}
