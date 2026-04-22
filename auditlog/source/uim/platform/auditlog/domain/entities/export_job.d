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
  mixin TenantEntity!(ExportJobId);

  UserId requestedBy;
  ExportFormat format_ = ExportFormat.json;
  ExportStatus status = ExportStatus.pending;
  AuditCategory[] categories; // filter by category
  long timeFrom;
  long timeTo;
  string downloadUrl; // set when completed
  long totalRecords;
  long completedAt;
  string errorMessage;

  Json toJson() const {
    return entityToJson()
      .set("requestedBy", requestedBy.toString)
      .set("format", format_.to!string)
      .set("status", status.to!string)
      .set("categories", categories.map!(c => to!string(c)).array.toJson)
      .set("timeFrom", timeFrom)
      .set("timeTo", timeTo)
      .set("downloadUrl", downloadUrl)
      .set("totalRecords", totalRecords)
      .set("completedAt", completedAt)
      .set("errorMessage", errorMessage);
  }
}
