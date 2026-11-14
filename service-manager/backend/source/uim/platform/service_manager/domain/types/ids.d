/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed identifiers. ServiceInstanceId, ServiceBindingId, SubaccountId,
/// TenantId and UserId come from uim-framework.
module uim.platform.service_manager.domain.types.ids;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct PlatformId {
  mixin(IdTemplate);
}

struct ServiceBrokerId {
  mixin(IdTemplate);
}

struct ServiceOfferingId {
  mixin(IdTemplate);
}

struct ServicePlanId {
  mixin(IdTemplate);
}

struct OperationId {
  mixin(IdTemplate);
}

struct LabelId {
  mixin(IdTemplate);
}

/// A new random identifier (UUID v4).
string newResourceId() @trusted {
  import std.uuid : randomUUID;

  return randomUUID().toString;
}

///
unittest {
  assert(newResourceId().length == 36);
  assert(newResourceId() != newResourceId());
  assert(PlatformId("p").value == "p" && PlatformId.init.isNull);
}
