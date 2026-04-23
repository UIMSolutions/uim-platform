/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.infrastructure.persistence.memory.certificates;

// import uim.platform.destination.domain.types;
// import uim.platform.destination.domain.entities.certificate;
// import uim.platform.destination.domain.ports.repositories.certificates;

// // import std.algorithm : filter;
// // import std.array : array;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
class MemoryCertificateRepository : CertificateRepository {
  private Certificate[CertificateId] store;

  bool existsById(CertificateId id) {
    return (id in store) ? true : false;
  }

  Certificate findById(CertificateId id) {
    return existsById(id) ? store[id] : Certificate.init;
  }

  bool existsByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    foreach (e; findAll())
      if (e.tenantId == tenantId && e.subaccountId == subaccountId && e.name == name)
        return true;
    return false;
  }

  Certificate findByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    foreach (e; findAll())
      if (e.tenantId == tenantId && e.subaccountId == subaccountId && e.name == name)
        return e;
    return Certificate.init;
  }

  Certificate[] findByTenant(TenantId tenantId) {
    return findAll().filter!(e => e.tenantId == tenantId).array;
  }

  Certificate[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findByTenant(tenantId).filter!(e => e.subaccountId == subaccountId).array;
  }

  Certificate[] findByType(TenantId tenantId, SubaccountId subaccountId, CertificateType type) {
    return findBySubaccount(tenantId, subaccountId).filter!(e => e.certificateType == type).array;
  }

  Certificate[] findExpiring(TenantId tenantId, long beforeTimestamp) {
    return findByTenant(tenantId).filter!(e => e.validTo > 0 && e.validTo <= beforeTimestamp).array;
  }

  void save(Certificate cert) {
    store[cert.id] = cert;
  }

  void update(Certificate cert) {
    store[cert.id] = cert;
  }

  void remove(CertificateId id) {
    store.remove(id);
  }
}
