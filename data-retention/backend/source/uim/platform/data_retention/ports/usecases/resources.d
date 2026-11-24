/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic driving port of a maintained resource (create, update, read,
/// list, delete). The specific ports below extend it with their operations.
module uim.platform.data_retention.ports.usecases.resources;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageResource(TEntity, TId, TInput) {
  TEntity create(CreateCommand!TInput c);
  TEntity update(UpdateCommand!TInput c);
  /// The entity or notFound.
  TEntity get(TenantId t, TId id);
  TEntity[] list(TenantId t);
  void remove(TenantId t, TId id, UserId actor);
}
