/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.remote_table;

// import uim.platform.datasphere.domain.types;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
struct ColumnDefinition {
  string name;
  string dataType;
  bool nullable;
  int length;
  int precision;
  int scale;
  string description;
}

struct RemoteTable {
  mixin TenantEntity!(RemoteTableId);

  SpaceId spaceId;
  ConnectionId connectionId;
  string name;
  string description;
  string remoteSchema;
  string remoteObjectName;
  ReplicationMode replicationMode;
  string replicationSchedule;
  ColumnDefinition[] columns;
  long rowCount;
  long lastReplicatedAt;
  
  Json toJson() const {
    auto j = entityToJson
      .set("spaceId", spaceId.value)
      .set("connectionId", connectionId.value)
      .set("name", name)
      .set("description", description)
      .set("remoteSchema", remoteSchema)
      .set("remoteObjectName", remoteObjectName)
      .set("replicationMode", replicationMode.toString())
      .set("replicationSchedule", replicationSchedule)
      .set("columns", columns.map!(col => Json()
        .set("name", col.name)
        .set("dataType", col.dataType)
        .set("nullable", col.nullable)
        .set("length", col.length)
        .set("precision", col.precision)
        .set("scale", col.scale)
        .set("description", col.description)).array)
      .set("rowCount", rowCount)
      .set("lastReplicatedAt", lastReplicatedAt);

    return j;
  }
}
