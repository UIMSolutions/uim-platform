/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.data_flow;

import uim.platform.datasphere.domain.types;

struct FlowSource {
  string objectId;
  string objectType;
  string[] columns;
}

struct FlowTarget {
  string objectId;
  string objectType;
  string truncateMode;
}

struct FlowTransform {
  string name;
  string type;
  string expression;
}

struct DataFlow {
  DataFlowId id;
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  FlowStatus status;
  FlowSource[] sources;
  FlowTarget target;
  FlowTransform[] transforms;
  string scheduleExpression;
  ScheduleFrequency scheduleFrequency;
  long lastRunAt;
  long lastRunDurationMs;
  string lastRunMessage;
  long createdAt;
  long modifiedAt;
}
