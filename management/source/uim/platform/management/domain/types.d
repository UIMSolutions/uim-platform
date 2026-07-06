/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.types;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.


struct DirectoryId {
  mixin(IdTemplate);
}


struct EntitlementId {
  mixin(IdTemplate);
}

struct EnvironmentId {
  mixin(IdTemplate);
}

struct SubscriptionId {
  mixin(IdTemplate);
}

struct ServicePlanId {
  mixin(IdTemplate);
}

struct EnvironmentEventId {
  mixin(IdTemplate);
}

struct LabelId {
  mixin(IdTemplate);
}

