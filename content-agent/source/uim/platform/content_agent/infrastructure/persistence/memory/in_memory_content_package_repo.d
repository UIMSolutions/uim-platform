/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.infrastructure.persistence.memory.in_memory_content_package_repo;

import uim.platform.content_agent.domain.types;
import uim.platform.content_agent.domain.entities.content_package;
import uim.platform.content_agent.domain.ports.content_package_repository;

// import std.algorithm : filter;
// import std.array : array;

class MemoryContentPackageRepository : ContentPackageRepository
{
  private ContentPackage[ContentPackageId] store;

  ContentPackage findById(ContentPackageId id)
  {
    if (auto p = id in store)
      return *p;
    return ContentPackage.init;
  }

  ContentPackage[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  ContentPackage[] findByStatus(TenantId tenantId, PackageStatus status)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  ContentPackage findByName(TenantId tenantId, string name)
  {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return ContentPackage.init;
  }

  void save(ContentPackage pkg)
  {
    store[pkg.id] = pkg;
  }

  void update(ContentPackage pkg)
  {
    store[pkg.id] = pkg;
  }

  void remove(ContentPackageId id)
  {
    store.remove(id);
  }
}
