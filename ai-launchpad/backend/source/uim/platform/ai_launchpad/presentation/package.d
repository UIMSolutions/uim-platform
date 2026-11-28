/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Presentation layer (driving adapters): OData v4 for SAP Fiori, REST,
/// the built-in login, health, the Fiori launchpad for local development,
/// the command line and the GtkD desktop GUI (only with --config=gui).
module uim.platform.ai_launchpad.presentation;

public {
  import uim.platform.ai_launchpad.presentation.odata;
  import uim.platform.ai_launchpad.presentation.http;
  import uim.platform.ai_launchpad.presentation.web;
  import uim.platform.ai_launchpad.presentation.cli;
}
