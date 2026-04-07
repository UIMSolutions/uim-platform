/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.entities.export_job;

// import uim.platform.auditlog.domain.types;

import uim.platform.auditlog;

mixin(ShowModule!());

/// An audit log export job.
@safe:
struct ExportJob {
  ExportJobId id;
  TenantId tenantId;
  UserId requestedBy;
  ExportFormat format_ = ExportFormat.json;
  ExportStatus status = ExportStatus.pending;
  AuditCategory[] categories; // filter by category
  long timeFrom;
  long timeTo;
  string downloadUrl; // set when completed
  long totalRecords;
  long createdAt;
  long completedAt;
  string errorMessage;

  Json toJson() const {
    return Json([
      "id": id,
      "tenantId": tenantId,
      "requestedBy": requestedBy,
      "format": format_,
      "status": status,
      "categories": categories,
      "timeFrom": timeFrom,
      "timeTo": timeTo,
      "downloadUrl": downloadUrl,
      "totalRecords": totalRecords,
      "createdAt": createdAt,
      "completedAt": completedAt,
      "errorMessage": errorMessage
    ]);
  }
}
