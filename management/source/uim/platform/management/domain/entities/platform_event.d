/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.platform_event;

// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// A platform event represents an auditable action or state change
/// on a BTP resource (subaccount created, entitlement changed, etc.).
struct PlatformEvent {
  PlatformEventId id;
  GlobalAccountId globalAccountId;
  SubaccountId subaccountId; // optional — if subaccount-scoped
  DirectoryId directoryId; // optional — if directory-scoped
  PlatformEventCategory category;
  PlatformEventSeverity severity = PlatformEventSeverity.info;
  string eventType; // e.g. "subaccount.created", "entitlement.assigned"
  string description;
  string resourceId; // ID of the affected resource
  string resourceType; // "subaccount", "entitlement", etc.
  string initiatedBy; // user or system
  string sourceService; // service that triggered the event
  long timestamp;
  string[string] details; // additional event data
}
