/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.task_chain;

// import uim.platform.datasphere.domain.types;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
struct ChainStep {
  int order;
  TaskId taskId;
  string onSuccess;
  string onFailure;

  Json toJson() const {
    return Json.emptyObject
      .set("order", order)
      .set("taskId", taskId)
      .set("onSuccess", onSuccess)
      .set("onFailure", onFailure);
  }
}

struct TaskChain {
  mixin TenantEntity!TaskChainId;
  
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
  
  Json toJson() const {
    auto stepsJson = Json.emptyArray;
    foreach (step; steps) {
      stepsJson ~= step.toJson();
    }

    return entityToJson
      .set("spaceId", spaceId)
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string())
      .set("steps", stepsJson)
      .set("scheduleExpression", scheduleExpression)
      .set("scheduleFrequency", scheduleFrequency.to!string())
      .set("lastRunAt", lastRunAt)
      .set("lastRunDurationMs", lastRunDurationMs)
      .set("lastRunMessage", lastRunMessage);
  }
}
