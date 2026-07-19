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
  mixin(IdTemplate);
}

struct ActivityId {
  mixin(IdTemplate);
}

struct AssignmentId {
  mixin(IdTemplate);
}

struct EquipmentId {
  mixin(IdTemplate);
}

struct TechnicianId {
  mixin(IdTemplate);
}

struct CustomerId {
  mixin(IdTemplate);
}

struct SkillId {
  mixin(IdTemplate);
}

struct SmartformId {
  mixin(IdTemplate);
}
