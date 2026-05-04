/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.entities.export_job;

// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// An export operation that packages and ships content to a transport queue or file.
struct ExportJob {
  mixin TenantEntity!(ExportJobId);

  ContentPackageId packageId;
  TransportRequestId transportRequestId;
  TransportQueueId queueId;
  ExportStatus status = ExportStatus.pending;
  string exportedFilePath;
  long exportedSizeBytes;
  long startedAt;
  long completedAt;
  string errorMessage;

  Json toJson() const {
    return entityToJson
      .set("packageId", packageId)
      .set("transportRequestId", transportRequestId)
      .set("queueId", queueId)
      .set("status", status.to!string)
      .set("exportedFilePath", exportedFilePath)
      .set("exportedSizeBytes", exportedSizeBytes)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt)
      .set("errorMessage", errorMessage);
  }
}
