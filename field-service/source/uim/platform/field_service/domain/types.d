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
