/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.persistence.repositories.base;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Tenant repository with predicate helpers for the scoped finders.
class PortalRepository(TEntity, TId) : TenantRepository!(TEntity, TId) {
  this() {
    super();
  }

  this(ITenantStore!(TEntity, TId) store) {
    super(store);
  }

  protected TEntity[] where(TenantId tenantId, scope bool delegate(TEntity) @safe predicate) {
    TEntity[] result;
    foreach (e; findByTenant(tenantId))
      if (predicate(e))
        result ~= e;
    return result;
  }

  protected TEntity first(TenantId tenantId, scope bool delegate(TEntity) @safe predicate) {
    foreach (e; findByTenant(tenantId))
      if (predicate(e))
        return e;
    return TEntity.init;
  }
}
