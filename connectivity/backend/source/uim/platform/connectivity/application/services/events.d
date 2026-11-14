/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.services.events;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Records connectivity events: one entry in the event log (monitoring /
/// audit) plus a message on the event publisher (integration).
class EventRecorder {
  protected ILogRepository logs;
  protected IConnectivityEventPublisher publisher;

  this(ILogRepository logs, IConnectivityEventPublisher publisher) {
    this.logs = logs;
    this.publisher = publisher;
  }

  /// Publish a lifecycle event ("connectivity.destination.created").
  void publish(string topic, Json payload) {
    publisher.publish(topic, payload);
  }

  /// Write a log entry (severity from the event type) and publish it.
  ConnectivityLogEntry log(TenantId tenantId, ConnectivityEventType type, SourceType sourceType,
      string sourceId, string sourceName, string message, string remoteHost = "", int remotePort = 0,
      UserId actor = UserId.init) {
    auto e = ConnectivityLogEntry(tenantId);
    e.eventType = type;
    e.severity = defaultSeverity(type);
    e.sourceType = sourceType;
    e.sourceId = sourceId;
    e.sourceName = sourceName;
    e.name = enumText(type) ~ (sourceName.length > 0 ? " · " ~ sourceName : "");
    e.message = message;
    e.remoteHost = remoteHost;
    e.remotePort = remotePort;
    e.occurredAt = e.createdAt;
    e.createdBy = actor;
    e.updatedBy = actor;
    logs.save(e);
    publisher.publish("connectivity.log." ~ enumText(type), encode(e, true));
    return e;
  }
}
