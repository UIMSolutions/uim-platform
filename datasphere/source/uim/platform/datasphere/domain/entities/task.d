/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.task;

import uim.platform.datasphere.domain.types;

struct Task {
  TaskId id;
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  TaskType type;
  TaskStatus status;
  string targetObjectId;
  string scheduleExpression;
  ScheduleFrequency scheduleFrequency;
  long startedAt;
  long completedAt;
  long lastRunDurationMs;
  string lastRunMessage;
  int retryCount;
  int maxRetries;
  long createdAt;
  long modifiedAt;
}
