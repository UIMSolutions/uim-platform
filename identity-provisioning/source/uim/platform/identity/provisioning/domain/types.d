/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.types;

import uim.platform.identity.provisioning;
mixin(ShowModule!());

@safe:
// --- Type Aliases ---
struct SourceSystemId {
  mixin(IdTemplate);
}

struct TargetSystemId {
  mixin(IdTemplate);
}

struct ProxySystemId {
  mixin(IdTemplate);
}

struct TransformationId {
  mixin(IdTemplate);
}

struct ProvisioningJobId {
  mixin(IdTemplate);
}

struct ProvisioningLogId {
  mixin(IdTemplate);
}

struct ProvisionedEntityId {
  mixin(IdTemplate);
}