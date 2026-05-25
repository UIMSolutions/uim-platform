/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.domain.entities.cleansing_job;
// import uim.platform.data_quality.domain.types;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
/// An asynchronous data cleansing job.
struct CleansingJob {
  mixin TenantEntity!(CleansingJobId);

  DatasetId datasetId;
  UserId requestedBy;
  JobStatus status = JobStatus.pending;
  CleansingRuleId[] ruleIds; // rules to apply

  long totalRecords;
  long processedRecords;
  long cleansedRecords; // records that were modified
  long errorRecords;

  string errorMessage;
  long startedAt;
  long completedAt;

  Json toJson() const {
    Json result = entityToJson
      .set("datasetId", datasetId)
      .set("requestedBy", requestedBy)
      .set("status", status.to!string)
      .set("ruleIds", ruleIds)
      .set("totalRecords", totalRecords)
      .set("processedRecords", processedRecords)
      .set("cleansedRecords", cleansedRecords)
      .set("errorRecords", errorRecords)
      .set("errorMessage", errorMessage)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt);

    if (errorMessage.length > 0)
      result["errorMessage"] = Json(errorMessage);

    if (ruleIds.length > 0) {
      auto ids = ruleIds.map!(id => Json(id)).array.toJson;
      result["ruleIds"] = ids;
    }

    return result;
  }
}