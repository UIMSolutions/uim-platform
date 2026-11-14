/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Outbound task events as structured log lines (the default ITaskEventPublisher;
/// replace with an Event Mesh / AMQP adapter to integrate other systems).
module uim.platform.task_center.infrastructure.logging.task_events;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class LoggingTaskEventPublisher : ITaskEventPublisher {
  void publish(const TaskDomainEvent e) nothrow {
    try {
      auto fields = Json.emptyObject;
      fields["type"] = e.type;
      fields["tenant"] = e.tenantId;
      fields["task"] = e.taskId;
      fields["actor"] = e.actor;
      if (e.data.type == Json.Type.object)
        fields["data"] = (() @trusted => e.data.clone)();
      logServiceEvent("info", "task event", fields);
    } catch (Exception) {
    }
  }
}

/// Keeps the events in memory (tests, CLI dry runs).
class RecordingTaskEventPublisher : ITaskEventPublisher {
  TaskDomainEvent[] events;

  void publish(const TaskDomainEvent e) nothrow {
    try
      events ~= TaskDomainEvent(e.type, e.tenantId, e.taskId, e.actor, e.occurredAt, Json(null));
    catch (Exception) {
    }
  }

  string[] types() const {
    return events.map!(e => e.type.idup).array;
  }
}

/// Publishes nothing.
class NullTaskEventPublisher : ITaskEventPublisher {
  void publish(const TaskDomainEvent e) nothrow {
  }
}
