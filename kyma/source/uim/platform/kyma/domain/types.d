/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct KymaEnvironmentId {
  mixin(IdTemplate);
}

struct NamespaceId {
  mixin(IdTemplate);
}

struct ServerlessFunctionId {
  mixin(IdTemplate);
}

struct ApiRuleId {
  mixin(IdTemplate);
}



struct EventSubscriptionId {
  mixin(IdTemplate);
}

struct KymaModuleId {
  mixin(IdTemplate);
}


struct ClusterId {
  mixin(IdTemplate);
}

