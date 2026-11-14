/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.ports.messaging.publisher;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Topics of the Agentry domain events.
enum AgentryTopics : string {
  applicationStatusChanged = "agentry.application.status-changed",
  definitionPublished = "agentry.definition.published",
  versionPublished = "agentry.version.published",
  versionWithdrawn = "agentry.version.withdrawn",
  deviceStatusChanged = "agentry.device.status-changed",
  syncCompleted = "agentry.sync.completed",
  syncFailed = "agentry.sync.failed",
  connectionTested = "agentry.connection.tested",
  deploymentStarted = "agentry.deployment.started",
  deploymentFinished = "agentry.deployment.finished",
  deploymentRolledBack = "agentry.deployment.rolled-back",
}

/// Driven port: publish domain events to a message broker (Event Mesh, Kafka …).
interface IAgentryEventPublisher {
  void publish(string topic, Json payload);
}

/// Publisher that drops all events (default when none is wired).
class NullEventPublisher : IAgentryEventPublisher {
  void publish(string topic, Json payload) {
  }
}
