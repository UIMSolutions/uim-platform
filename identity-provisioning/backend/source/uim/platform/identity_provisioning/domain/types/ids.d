/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Strongly typed identifiers of the provisioning aggregates.
/// (TenantId and UserId come from uim-framework.)
module uim.platform.identity_provisioning.domain.types.ids;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// A system identities are read from (HR, directory, IAS, ...).
struct SourceSystemId {
  mixin(IdTemplate);
}

/// A system identities are written to.
struct TargetSystemId {
  mixin(IdTemplate);
}

/// A system that exposes the provisioning engine to an external consumer (SCIM proxy).
struct ProxySystemId {
  mixin(IdTemplate);
}

/// An attribute mapping / filter for one system.
struct TransformationId {
  mixin(IdTemplate);
}

/// A provisioning job (source → target synchronisation).
struct ProvisioningJobId {
  mixin(IdTemplate);
}

/// One audit entry of a job run.
struct ProvisioningLogId {
  mixin(IdTemplate);
}

/// A user or group as provisioned into a target system.
struct ProvisionedEntityId {
  mixin(IdTemplate);
}
