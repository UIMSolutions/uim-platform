/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Presentation layer — driving adapters: REST (http), vibe.d REST interfaces
/// (rest), OData v4 (odata), Fiori static files (web) and the CLI. The GtkD GUI
/// is imported explicitly by source/gui.d (only built with --config=gui).
module uim.platform.agentry.presentation;

public {
  import uim.platform.agentry.presentation.payloads;
  import uim.platform.agentry.presentation.tabular;
  import uim.platform.agentry.presentation.http;
  import uim.platform.agentry.presentation.rest;
  import uim.platform.agentry.presentation.odata;
  import uim.platform.agentry.presentation.web;
  import uim.platform.agentry.presentation.cli;
}
