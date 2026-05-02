/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.transport_request;

// import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Individual task within a transport request.
struct TransportTask {
  string taskId;
  string owner;
  TransportStatus status = TransportStatus.modifiable;
  string description;
  string[] objectList;
  long createdAt;
  long releasedAt;
}

/// Transport request for managing changes between systems (CTS-like).
struct TransportRequest {
  mixin TenantEntity!(TransportRequestId);

  SystemInstanceId sourceSystemId;
  SystemInstanceId targetSystemId;
  string description;
  string owner;

  TransportType transportType = TransportType.workbench;
  TransportStatus status = TransportStatus.modifiable;

  /// Tasks belonging to this request
  TransportTask[] tasks;

  /// Metadata
  long releasedAt;
  long importedAt;

  Json toJson() const {
    auto j = entityToJson
      .set("sourceSystemId", sourceSystemId)
      .set("targetSystemId", targetSystemId)
      .set("description", description)
      .set("owner", owner)
      .set("transportType", transportType.to!string)
      .set("status", status.to!string)
      .set("createdAt", createdAt)
      .set("releasedAt", releasedAt)
      .set("importedAt", importedAt);

    if (tasks.length > 0) {
      auto ts = tasks.map!(t => Json.emptyObject
        .set("taskId", t.taskId)
        .set("owner", t.owner)
        .set("status", t.status.to!string)
        .set("description", t.description)
        .set("objectList", t.objectList.array.toJson())
        .set("createdAt", t.createdAt)
        .set("releasedAt", t.releasedAt))();
      j["tasks"] = ts;
    }

    return j;
  }
}
