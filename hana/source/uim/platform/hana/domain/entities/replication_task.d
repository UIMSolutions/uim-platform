/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.replication_task;

// import uim.platform.hana.domain.types;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct ReplicationMapping {
  string sourceSchema;
  string sourceTable;
  string targetSchema;
  string targetTable;

  Json toJson() const {
    return Json.emptyObject
      .set("sourceSchema", sourceSchema)
      .set("sourceTable", sourceTable)
      .set("targetSchema", targetSchema)
      .set("targetTable", targetTable);
  }
}

struct ReplicationTask {
  mixin TenantEntity!(ReplicationTaskId);

  DatabaseInstanceId instanceId;
  string name;
  string description;
  ReplicationMode mode;
  ReplicationTaskStatus status;
  string sourceConnectionId;
  string targetConnectionId;
  ReplicationMapping[] mappings;
  string scheduleExpression;
  long lastRunAt;
  long nextRunAt;
  long rowsReplicated;
  long errorCount;
  
  Json toJson() const {
    return entityToJson
      .set("instanceId", instanceId.value)
      .set("name", name)
      .set("description", description)
      .set("mode", mode.toString())
      .set("status", status.toString())
      .set("sourceConnectionId", sourceConnectionId)
      .set("targetConnectionId", targetConnectionId)
      .set("mappings", mappings.map!(m => m.toJson()).array)
      .set("scheduleExpression", scheduleExpression)
      .set("lastRunAt", lastRunAt)
      .set("nextRunAt", nextRunAt)
      .set("rowsReplicated", rowsReplicated)
      .set("errorCount", errorCount);
  }
}
