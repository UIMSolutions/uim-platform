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
  TenantId tenantId;
  ImportJobId id;
  ContentPackageId packageId;
  TransportRequestId transportRequestId;
  ImportStatus status = ImportStatus.pending;
  string sourceFilePath;
  long importedSizeBytes;
  UserId createdBy;
  long startedAt;
  long completedAt;
  string errorMessage;
  string[] deployedItems;
}
