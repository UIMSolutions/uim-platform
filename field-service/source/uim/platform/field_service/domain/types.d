/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.types;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

// --- ID Aliases ---
struct ServiceCallId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ActivityId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct AssignmentId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct EquipmentId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TechnicianId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct CustomerId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SkillId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SmartformId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}





// --- Enumerations ---

enum ServiceCallStatus {
    draft,
    new_,
    assigned,
    inProgress,
    onHold,
    resolved,
    closed,
    cancelled
}

enum ServiceCallPriority {
    low,
    medium,
    high,
    critical
}

enum ServiceCallOrigin {
    manual,
    selfService,
    email,
    phone,
    iot,
    integration
}

enum ServiceCallCategory {
    repair,
    installation,
    maintenance,
    inspection,
    warranty,
    emergency,
    consultation,
    other
}

enum ActivityType {
    serviceTask,
    meeting,
    phoneCall,
    travelTime,
    breakTime,
    followUp,
    inspection,
    installation,
    repair,
    maintenance
}

enum ActivityStatus {
    draft,
    planned,
    released,
    dispatched,
    accepted,
    inTravel,
    onSite,
    inProgress,
    completed,
    cancelled
}

enum AssignmentStatus {
    proposed,
    assigned,
    accepted,
    rejected,
    inProgress,
    completed,
    cancelled
}

enum EquipmentStatus {
    active,
    inactive,
    inRepair,
    decommissioned,
    scrapped
}

enum EquipmentType {
    machine,
    tool,
    vehicle,
    sensor,
    hvac,
    electrical,
    plumbing,
    it,
    custom
}

enum TechnicianStatus {
    available,
    busy,
    onLeave,
    offline,
    inactive
}

enum CustomerType {
    commercial,
    residential,
    industrial,
    government,
    internal
}

enum CustomerStatus {
    active,
    inactive,
    prospect,
    blocked
}

enum SkillCategory {
    technical,
    certification,
    product,
    safety,
    language,
    soft,
    custom
}

enum ProficiencyLevel {
    beginner,
    intermediate,
    advanced,
    expert,
    master
}

enum SmartformType {
    checklist,
    serviceReport,
    inspection,
    safety,
    feedback,
    survey,
    workInstruction,
    handover,
    custom
}

enum SmartformStatus {
    draft,
    inProgress,
    submitted,
    approved,
    rejected,
    archived
}
