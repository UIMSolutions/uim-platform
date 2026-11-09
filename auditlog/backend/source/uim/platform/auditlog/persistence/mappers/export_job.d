/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.persistence.mappers.export_job;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

struct ExportJobMapper {
  static Json toRecord(const ExportJob e) {
    auto r = baseRecord(e);
    r["requestedBy"] = e.requestedBy.value;
    r["format"] = e.format_.to!string;
    r["status"] = e.status.to!string;
    r["categories"] = categoriesToJson(e.categories);
    r["timeFrom"] = e.timeFrom;
    r["timeTo"] = e.timeTo;
    r["downloadUrl"] = e.downloadUrl;
    r["totalRecords"] = e.totalRecords;
    r["completedAt"] = e.completedAt;
    r["errorMessage"] = e.errorMessage;
    return r;
  }

  static ExportJob fromRecord(Json r) {
    ExportJob e;
    readBase(e, r);
    e.requestedBy = UserId(fieldString(r, "requestedBy"));
    e.format_ = fieldEnum!ExportFormat(r, "format", ExportFormat.json);
    e.status = fieldEnum!ExportStatus(r, "status", ExportStatus.pending);
    e.categories = categoriesFromJson(r, "categories");
    e.timeFrom = fieldLong(r, "timeFrom");
    e.timeTo = fieldLong(r, "timeTo");
    e.downloadUrl = fieldString(r, "downloadUrl");
    e.totalRecords = fieldLong(r, "totalRecords");
    e.completedAt = fieldLong(r, "completedAt");
    e.errorMessage = fieldString(r, "errorMessage");
    return e;
  }
}
