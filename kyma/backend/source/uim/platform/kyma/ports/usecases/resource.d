/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.usecases.resource;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driving port shape shared by all aggregates: create / update / remove /
/// read and rendering of the Kubernetes manifest.
///
/// Mutations return a UsecaseResult; on failure `code` carries an HTTP-like
/// status (404 not found, 409 conflict, 422 business rule violated).
interface IManageResource(TEntity, TId, TCreate, TUpdate) {
  UsecaseResult create(TCreate request);
  UsecaseResult update(TUpdate request);
  UsecaseResult remove(TenantId tenantId, TId id, UserId actor);

  /// TEntity.init (isNull) if not found.
  TEntity get(TenantId tenantId, TId id);
  TEntity[] list(TenantId tenantId);

  /// The custom resource(s) Kyma reconciles; Json(null) if not found.
  Json manifest(TenantId tenantId, TId id);
}
