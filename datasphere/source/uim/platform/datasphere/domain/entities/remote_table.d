/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.remote_table;

import uim.platform.datasphere.domain.types;

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
  RemoteTableId id;
  TenantId tenantId;
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
  long createdAt;
  long modifiedAt;
}
