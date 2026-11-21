/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Presentation layer: driving adapters.
///   http   REST API (/api/v1), CSV import, health
///   odata  OData v4 for the SAP Fiori app ($metadata, $batch)
///   web    the Fiori app for local development (/app)
///   cli    command line administration
///   gui    GtkD desktop browser (--config=gui)
module uim.platform.data_quality.presentation;

public {
  import uim.platform.data_quality.presentation.odata;
  import uim.platform.data_quality.presentation.http;
  import uim.platform.data_quality.presentation.web;
  import uim.platform.data_quality.presentation.cli;
}
