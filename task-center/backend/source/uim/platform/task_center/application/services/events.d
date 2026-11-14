/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Building and publishing task domain events.
module uim.platform.task_center.application.services.events;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

void publishTaskEvent(ITaskEventPublisher events, const UIMTask t, string step, string actor, Json data = Json.emptyObject) {
  if (events is null)
    return;
  TaskDomainEvent e;
  e.type = taskEventType(step);
  e.tenantId = t.tenantId.value;
  e.taskId = t.id.value;
  e.actor = actor;
  e.occurredAt = nowStdTime();
  e.data = data.type == Json.Type.object ? data : Json.emptyObject;
  e.data["title"] = t.title;
  e.data["status"] = cast(string) t.status;
  events.publish(e);
}
