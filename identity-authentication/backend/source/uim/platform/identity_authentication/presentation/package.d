/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Presentation layer — driving adapters: REST (http), vibe.d REST interfaces
/// (rest), OData v4 (odata), Fiori static files (web) and the CLI. The GtkD GUI
/// is imported explicitly by source/gui.d (only built with --config=gui).
module uim.platform.identity_authentication.presentation;

public {
  import uim.platform.identity_authentication.presentation.payloads;
  import uim.platform.identity_authentication.presentation.tabular;
  import uim.platform.identity_authentication.presentation.http;
  import uim.platform.identity_authentication.presentation.rest;
  import uim.platform.identity_authentication.presentation.odata;
  import uim.platform.identity_authentication.presentation.web;
  import uim.platform.identity_authentication.presentation.cli;
}
