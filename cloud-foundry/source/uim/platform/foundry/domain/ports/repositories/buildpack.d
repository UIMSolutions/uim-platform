/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.buildpack;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.buildpack;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying buildpacks.
interface IBuildpackRepository : ITenantRepository!(Buildpack, BuildpackId) {
  bool existsByName(TenantId tenantId, string name);
  Buildpack findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);
  
  size_t countEnabled(TenantId tenantId);
  Buildpack[] findEnabled(TenantId tenantId);
  void removeEnabled(TenantId tenantId);

  size_t countEnabled(TenantId tenantId);
  Buildpack[] findEnabled(TenantId tenantId);
  void removeEnabled(TenantId tenantId);
}
