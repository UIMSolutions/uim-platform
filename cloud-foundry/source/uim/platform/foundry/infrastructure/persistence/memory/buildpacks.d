/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.buildpacks;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.buildpack;
// import uim.platform.foundry.domain.ports.repositories.buildpack;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class MemoryBuildpackRepository : TenantRepository!(Buildpack, BuildpackId), IBuildpackRepository {

  bool existsByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return true;
    return false;
  }

  Buildpack findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return Buildpack.init;
  }

  void removeByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return remove(e);
  }

  // #region Enabled 
  // Buildpacks can be enabled/disabled globally, but also filtered by stack. So we need to be able to find them by these criteria.
  size_t countEnabled(TenantId tenantId) {
    return findEnabled(tenantId).length;
  }

  Buildpack[] filterEnabled(Buildpack[] buildpacks) {
    return buildpacks.filter!(e => e.enabled).array;
  }

  Buildpack[] findEnabled(TenantId tenantId) {
    return filterEnabled(findByTenant(tenantId));
  }

  void removeEnabled(TenantId tenantId) {
    findEnabled(tenantId).each!(e => remove(e));
  }
  // #endregion Enabled

  // #region ByStack
  size_t countByStack(TenantId tenantId, string stack) {
    return findByStack(tenantId, stack).length;
  }

  Buildpack[] filterByStack(Buildpack[] buildpacks, string stack) {
    return buildpacks.filter!(e => e.stack == stack).array;
  }

  Buildpack[] findByStack(TenantId tenantId, string stack) {
    return filterByStack(findByTenant(tenantId), stack);
  }

  void removeByStack(TenantId tenantId, string stack) {
    findByStack(tenantId, stack).each!(e => remove(e));
  }
  // #endregion ByStack

}
