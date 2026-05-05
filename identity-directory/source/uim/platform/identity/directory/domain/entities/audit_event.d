/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.entities.audit_event;

// import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// Immutable audit log entry.
struct AuditEvent {
      mixin TenantEntity!AuditEventId;

  AuditEventType eventType;
  string actorId; // user or client that performed the action
  string actorType; // "User", "ApiClient", "System"
  string targetId; // affected resource ID
  string targetType; // "User", "Group", "Schema", etc.
  string description;
  string ipAddress;
  string userAgent;
  string[string] details; // additional key-value metadata
  long timestamp;

  Json toJson() const {
    return entityToJson
      .set("eventType", eventType.to!string)
      .set("actorId", actorId)
      .set("actorType", actorType)
      .set("targetId", targetId)
      .set("targetType", targetType)
      .set("description", description)
      .set("ipAddress", ipAddress)
      .set("userAgent", userAgent)
      .set("details", details)
      .set("timestamp", timestamp);
  }
}
