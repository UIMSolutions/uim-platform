/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.entities.import_job;

// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// An import operation that deploys a content package into the target landscape.
struct ImportJob {
  mixin TenantEntity!(ImportJobId);

  ContentPackageId packageId;
  TransportRequestId transportRequestId;
  ImportStatus status = ImportStatus.pending;
  string sourceFilePath;
  long importedSizeBytes;
  long startedAt;
  long completedAt;
  string errorMessage;
  string[] deployedItems;

  Json toJson() const {
    return entityToJson
      .set("packageId", packageId)
      .set("transportRequestId", transportRequestId)
      .set("status", status.to!string)
      .set("sourceFilePath", sourceFilePath)
      .set("importedSizeBytes", importedSizeBytes)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt)
      .set("errorMessage", errorMessage)
      .set("deployedItems", deployedItems);
  }
}
