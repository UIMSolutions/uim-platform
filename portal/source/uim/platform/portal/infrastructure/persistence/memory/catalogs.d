/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.persistence.memory.catalogs;

// import uim.platform.portal.domain.entities.catalog;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.catalogs;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

class MemoryCatalogRepository : CatalogRepository {
  private Catalog[CatalogId] store;

  bool existsById(CatalogId id) {
    return (id in store) ? true : false;
  }

  Catalog findById(CatalogId id) {
    return existsById(id) ? store[id] : Catalog.init;
  }

  Catalog[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100) {
    Catalog[] result;
    uint idx;
    foreach (c; store.byValue()) {
      if (c.tenantId == tenantId) {
        if (idx >= offset && result.length < limit)
          result ~= c;
        idx++;
      }
    }
    return result;
  }

  Catalog[] findByProvider(ProviderId providerId) {
    Catalog[] result;
    foreach (c; store.byValue()) {
      if (c.providerId == providerId)
        result ~= c;
    }
    return result;
  }

  void save(Catalog catalog) {
    store[catalog.id] = catalog;
  }

  void update(Catalog catalog) {
    store[catalog.id] = catalog;
  }

  void remove(CatalogId id) {
    store.remove(id);
  }
}
