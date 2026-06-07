/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.environment_event;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
/// A platform event represents an auditable action or state change
/// on a BTP resource (subaccount created, entitlement changed, etc.).
struct EnvironmentEvent {
  mixin TenantEntity!EnvironmentEventId;

  GlobalAccountId globalAccountId;
  SubaccountId subaccountId; // optional — if subaccount-scoped
  DirectoryId directoryId; // optional — if directory-scoped
  EnvironmentEventCategory category;
  EnvironmentEventSeverity severity = EnvironmentEventSeverity.info;
  string eventType; // e.g. "subaccount.created", "entitlement.assigned"
  string description;
  string resourceId; // ID of the affected resource
  string resourceType; // "subaccount", "entitlement", etc.
  UserId initiatedBy; // user or system
  string sourceService; // service that triggered the event
  long timestamp;
  string[string] details; // additional event data

  Json toJson() const {
    auto jDetail = Json.emptyObject;
    foreach (key, value; details) {
      jDetail.set(key, value);
    }

    return entityToJson
        .set("globalAccountId", globalAccountId)
        .set("subaccountId", subaccountId)
        .set("directoryId", directoryId)
        .set("category", category.to!string)
        .set("severity", severity.to!string)
        .set("eventType", eventType)
        .set("description", description)
        .set("resourceId", resourceId)
        .set("resourceType", resourceType)
        .set("initiatedBy", initiatedBy)
        .set("sourceService", sourceService)
        .set("timestamp", timestamp)
        .set("details", jDetail);
  }
}
