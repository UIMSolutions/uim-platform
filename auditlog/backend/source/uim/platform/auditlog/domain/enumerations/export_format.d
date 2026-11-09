/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.enumerations.export_format;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Export output format.
enum ExportFormat {
  json,
  csv,
}

ExportFormat toExportFormat(string value) {
  mixin(EnumSwitch("ExportFormat", "json"));
}

ExportFormat[] toExportFormat(string[] values) {
  return values.map!toExportFormat.array;
}

string toString(ExportFormat f) {
  return f.to!string;
}

string[] toString(ExportFormat[] formats) {
  return formats.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("ExportFormat"));

  assert("json".toExportFormat == ExportFormat.json);
  assert("csv".toExportFormat == ExportFormat.csv);

  assert(ExportFormat.json.toString == "json");
  assert(ExportFormat.csv.toString == "csv");

  assert(["json", "csv"].toExportFormat == [ExportFormat.json, ExportFormat.csv
    ]);
  assert([ExportFormat.json, ExportFormat.csv].toString == ["json", "csv"]);
}

