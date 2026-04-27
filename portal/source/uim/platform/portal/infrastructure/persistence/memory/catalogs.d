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

class MemoryCatalogRepository :TenantRepository!(Catalog, CatalogId), CatalogRepository {

  size_t countByProvider(ProviderId providerId) {
    return findByProvider(providerId).length;
  }

  Catalog[] filterByProvider(Catalog[] catalogs, ProviderId providerId) {
    return catalogs.filter!(c => c.providerId == providerId).array;
  }

  Catalog[] findByProvider(ProviderId providerId) {
    return findAll().filter!(c => c.providerId == providerId).array;
  }

  void removeByProvider(ProviderId providerId) {
    findByProvider(providerId).each!(c => remove(c.id));
  }

}
