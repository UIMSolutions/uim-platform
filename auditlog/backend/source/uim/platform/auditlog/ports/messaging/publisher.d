/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.ports.messaging.publisher;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Driven port: publish audit domain events to a broker (Event Mesh, Kafka, log, ...).
interface IAuditEventPublisher {
  void publish(string topic, Json payload);
}

/// Topics published by the audit log service.
enum AuditTopics : string {
  entryWritten = "auditlog/entry/written",
  retentionEnforced = "auditlog/retention/enforced",
  exportCompleted = "auditlog/export/completed",
}
