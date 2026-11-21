/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Presentation layer: driving adapters.
///   http   AI API v2 (/api/v2/lm, /api/v2/admin), health
///   odata  OData v4 for the SAP Fiori app ($metadata, $batch)
///   web    the Fiori app for local development (/app)
///   cli    command line administration
///   gui    GtkD desktop browser (--config=gui)
module uim.platform.ai_core.presentation;

public {
  import uim.platform.ai_core.presentation.odata;
  import uim.platform.ai_core.presentation.http;
  import uim.platform.ai_core.presentation.web;
  import uim.platform.ai_core.presentation.cli;
  import uim.platform.ai_core.presentation.rest;
  import uim.platform.ai_core.presentation.unix;
}
