/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.buildpack;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.buildpack;

/// Port for persisting and querying buildpacks.
interface IBuildpackRepository
{
  Buildpack[] findByTenant(TenantId tenantId);
  Buildpack* findById(BuildpackId id, TenantId tenantId);
  Buildpack* findByName(TenantId tenantId, string name);
  Buildpack[] findEnabled(TenantId tenantId);
  Buildpack[] findByStack(TenantId tenantId, string stack);
  void save(Buildpack buildpack);
  void update(Buildpack buildpack);
  void remove(BuildpackId id, TenantId tenantId);
}
