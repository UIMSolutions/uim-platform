/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.task;

// import uim.platform.workzone.domain.types;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// A unified task — aggregated from multiple backend systems into a single inbox.
struct WZTask {
  mixin TenantEntity!(TaskId);

  UserId assigneeId;
  string assigneeName;
  UserId creatorId;
  string creatorName;
  string title;
  string description;
  TaskStatus status = TaskStatus.open;
  TaskPriority priority = TaskPriority.medium;
  string sourceApp; // originating system
  string sourceTaskId; // original task ID in source
  string actionUrl; // deep link to source
  string category;
  string[] tags;
  long dueDate;
  long completedAt;

  Json toJson() const {
    auto j = entityToJson
      .set("assigneeId", assigneeId.value)
      .set("assigneeName", assigneeName)
      .set("creatorId", creatorId.value)
      .set("creatorName", creatorName)
      .set("title", title)
      .set("description", description)
      .set("status", status.to!string())
      .set("priority", priority.to!string())
      .set("sourceApp", sourceApp)
      .set("sourceTaskId", sourceTaskId)
      .set("actionUrl", actionUrl)
      .set("category", category)
      .set("tags", tags.toJson)
      .set("dueDate", dueDate)
      .set("completedAt", completedAt);

    return j;
  }
}
