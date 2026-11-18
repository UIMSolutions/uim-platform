/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.ports.usecases.transformations;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Maintain attribute mappings and entity filters.
interface IManageTransformationsUseCase : IManageResource!(Transformation, TransformationId,
    CreateTransformationRequest, UpdateTransformationRequest) {
  UsecaseResult activate(TenantId tenantId, TransformationId id, UserId actor);
  UsecaseResult deactivate(TenantId tenantId, TransformationId id, UserId actor);
  /// Apply one transformation to sample attributes (nothing is stored).
  TransformationPreview preview(TenantId tenantId, TransformationId id, EntityType entityType, Attribute[] sample);
  /// The transformations of a system, in application order.
  Transformation[] forSystem(TenantId tenantId, SystemRole role, string systemId);
  Transformation findByName(TenantId tenantId, string name);
}
