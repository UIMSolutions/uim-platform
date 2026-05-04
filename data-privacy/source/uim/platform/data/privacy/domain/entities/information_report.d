/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.information_report;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// An information report — generated report about a data subject's personal data.
struct InformationReport {
  mixin TenantEntity!(InformationReportId);

  DataSubjectId dataSubjectId;
  DataSubjectType subjectRole;
  UserId requestedBy;
  InformationReportStatus status = InformationReportStatus.requested;
  ExportFormat format = ExportFormat.pdf;
  string[] targetSystems; // systems queried
  PersonalDataCategory[] categories; // filter by category
  string downloadUrl; // set when completed
  long totalRecords; // count of records in the report
  string reason;
  long requestedAt;
  long generatedAt;
  long expiresAt; // download link expiry

  Json toJson() const {
    return entityToJson
      .set("dataSubjectId", dataSubjectId)
      .set("subjectRole", subjectRole.to!string)
      .set("requestedBy", requestedBy)
      .set("status", status.to!string)
      .set("format", format.to!string)
      .set("targetSystems", targetSystems)
      .set("categories", categories)
      .set("downloadUrl", downloadUrl)
      .set("totalRecords", totalRecords)
      .set("reason", reason)
      .set("requestedAt", requestedAt)
      .set("generatedAt", generatedAt)
      .set("expiresAt", expiresAt);
  }
}
