/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Presentation layer: driving adapters.
///   odata  OData v4 for the SAP Fiori app ($metadata, $batch) — the engine behind every adapter
///   http   REST facade (/api/v1) and health
///   web    the Fiori app for local development (/app)
///   cli    command line administration
///   gui    GtkD desktop browser (--config=gui)
module uim.platform.architecture.presentation;

public {
  import uim.platform.architecture.presentation.odata;
  import uim.platform.architecture.presentation.http;
  import uim.platform.architecture.presentation.web;
  import uim.platform.architecture.presentation.cli;
}
