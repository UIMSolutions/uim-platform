/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.enumerations.export_status;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Export job status.
enum ExportStatus {
  pending,
  inProgress,
  completed,
  failed,
}

ExportStatus toExportStatus(string value) {
  mixin(EnumSwitch("ExportStatus", "pending"));
}

ExportStatus[] toExportStatus(string[] values) {
  return values.map!toExportStatus.array;
}

string toString(ExportStatus s) {
  return s.to!string;
}

string[] toString(ExportStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("ExportStatus"));

  assert("pending".toExportStatus == ExportStatus.pending);
  assert("inProgress".toExportStatus == ExportStatus.inProgress);
  assert("completed".toExportStatus == ExportStatus.completed);
  assert("failed".toExportStatus == ExportStatus.failed);

  assert(ExportStatus.pending.toString == "pending");
  assert(ExportStatus.inProgress.toString == "inProgress");
  assert(ExportStatus.completed.toString == "completed");
  assert(ExportStatus.failed.toString == "failed");

  assert(["pending", "completed"].toExportStatus == [ExportStatus.pending, ExportStatus.completed
    ]);
  assert([ExportStatus.pending, ExportStatus.completed].toString == ["pending", "completed"
    ]);
}

