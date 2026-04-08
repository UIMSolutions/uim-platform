/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.persistence.memory.certificate;

// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.certificate;
// import uim.platform.connectivity.domain.ports.repositories.certificates;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class MemoryCertificateRepository : CertificateRepository {
  private Certificate[CertificateId] store;

  Certificate findById(CertificateId id) {
    if (auto p = id in store)
      return *p;
    return Certificate.init;
  }

  Certificate findByName(TenantId tenantId, string name) {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return Certificate.init;
  }

  Certificate[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  Certificate[] findExpiring(TenantId tenantId, long now, uint withinDays) {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.expiresWithinDays(now, withinDays)).array;
  }

  void save(Certificate entity) {
    store[entity.id] = entity;
  }

  void update(Certificate entity) {
    store[entity.id] = entity;
  }

  void remove(CertificateId id) {
    store.remove(id);
  }
}
