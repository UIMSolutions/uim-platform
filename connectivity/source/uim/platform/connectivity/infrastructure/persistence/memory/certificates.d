/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.persistence.memory.certificates;

// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.certificate;
// import uim.platform.connectivity.domain.ports.repositories.certificates;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class MemoryCertificateRepository : TenantRepository!(Certificate, CertificateId), CertificateRepository {

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(e => e.name == name);
  }

  Certificate findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return Certificate.init;
  }

  void removeByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return remove(e);
  }

  size_t countExpiring(TenantId tenantId, long now, size_t withinDays) {
    return findExpiring(tenantId, now, withinDays).length;
  }

  Certificate[] findExpiring(TenantId tenantId, long now, size_t withinDays) {
    return findByTenant(tenantId).filter!(e => e.expiresWithinDays(now, withinDays)).array;
  }

  void removeExpiring(TenantId tenantId, long now, size_t withinDays) {
    findExpiring(tenantId, now, withinDays).each!(e => remove(e));
  }

}
