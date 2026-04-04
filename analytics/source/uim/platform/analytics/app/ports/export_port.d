/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.ports.export_port;
@safe:

/// Outgoing port: export analytics artifacts to various formats.
interface ExportPort {
  /// Export artifact to PDF bytes.
  ubyte[] exportPdf(string artifactId, string artifactType);

  /// Export data to CSV string.
  string exportCsv(string datasetId, string[] columns);

  /// Export data to Excel bytes.
  ubyte[] exportExcel(string datasetId, string[] columns);
}
