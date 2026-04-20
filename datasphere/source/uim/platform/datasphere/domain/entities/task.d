/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.task;

import uim.platform.datasphere.domain.types;

struct Task {
  mixin TenantEntity!(TaskId);

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
  
  Json toJson() const {
    auto j = entityToJson
      .set("spaceId", spaceId)
      .set("name", name)
      .set("description", description)
      .set("type", type.to!string)
      .set("status", status.to!string)
      .set("targetObjectId", targetObjectId)
      .set("scheduleExpression", scheduleExpression)
      .set("scheduleFrequency", scheduleFrequency.to!string)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt)
      .set("lastRunDurationMs", lastRunDurationMs)
      .set("lastRunMessage", lastRunMessage)
      .set("retryCount", retryCount)
      .set("maxRetries", maxRetries);

    return j;
  }
}
