/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port for outbound domain events (task created, claimed, decided …),
/// e.g. towards an event broker such as SAP Event Mesh.
module uim.platform.task_center.ports.messaging.task_events;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct TaskDomainEvent {
  string type; /// "sap.taskcenter.task.created", "….task.claimed", …
  string tenantId;
  string taskId;
  string actor;
  long occurredAt; /// std time
  Json data; /// event specific details
}

interface ITaskEventPublisher {
  /// Must not throw: delivery problems are the publisher's concern.
  void publish(const TaskDomainEvent event) nothrow;
}

/// Event type for a task lifecycle step ("created", "claimed", …).
string taskEventType(string step) pure {
  return "sap.taskcenter.task." ~ step;
}
