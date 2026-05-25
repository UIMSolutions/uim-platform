/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.entities.composition_run;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:

/// Represents a single execution run of the Data Composer unification pipeline.
struct CompositionRun {
  mixin TenantEntity!(CompositionRunId);

  string name;
  CompositionRunStatus status;
  long   startedAt;
  long   finishedAt;
  long   totalInputRecords;
  long   processedRecords;
  long   createdProfiles;
  long   mergedProfiles;
  long   failedRecords;
  string triggeredBy;    /// user id or "SYSTEM"
  string errorMessage;
  string[] dataProductIds; /// Which data products were included
  string[string] metadata;

  Json toJson() const {
    auto dpArr = Json.emptyArray;
    foreach (d; dataProductIds) dpArr ~= Json(d);

    return entityToJson()
      .set("name", name)
      .set("status", status.to!string)
      .set("startedAt", startedAt)
      .set("finishedAt", finishedAt)
      .set("totalInputRecords", totalInputRecords)
      .set("processedRecords", processedRecords)
      .set("createdProfiles", createdProfiles)
      .set("mergedProfiles", mergedProfiles)
      .set("failedRecords", failedRecords)
      .set("triggeredBy", triggeredBy)
      .set("errorMessage", errorMessage)
      .set("dataProductIds", dpArr);
  }
}
