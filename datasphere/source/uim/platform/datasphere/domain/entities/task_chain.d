/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.task_chain;

import uim.platform.datasphere.domain.types;

struct ChainStep {
  int order;
  TaskId taskId;
  string onSuccess;
  string onFailure;
}

struct TaskChain {
  TaskChainId id;
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  TaskStatus status;
  ChainStep[] steps;
  string scheduleExpression;
  ScheduleFrequency scheduleFrequency;
  long lastRunAt;
  long lastRunDurationMs;
  string lastRunMessage;
  long createdAt;
  long modifiedAt;
}
