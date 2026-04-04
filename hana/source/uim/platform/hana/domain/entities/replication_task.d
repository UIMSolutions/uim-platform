/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.replication_task;

import uim.platform.hana.domain.types;

struct ReplicationMapping {
  string sourceSchema;
  string sourceTable;
  string targetSchema;
  string targetTable;
}

struct ReplicationTask {
  ReplicationTaskId id;
  TenantId tenantId;
  InstanceId instanceId;
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
  long createdAt;
  long modifiedAt;
}
