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
class MemoryCertificateRepository : TenantRepository!(Certificate, CertificateId), CertificateRepository {

  bool existsByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.subaccountId == subaccountId && e.name == name)
        return true;
    return false;
  }

  Certificate findByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.subaccountId == subaccountId && e.name == name)
        return e;
    return Certificate.init;
  }

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findBySubaccount(tenantId, subaccountId).length;
  }
  Certificate[] filterBySubaccount(Certificate[] certs, SubaccountId subaccountId) {
    return certs.filter!(e => e.subaccountId == subaccountId).array;
  }
  Certificate[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return filterBySubaccount(findByTenant(tenantId), subaccountId);
  }
  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    findBySubaccount(tenantId, subaccountId).each!(e => remove(e));
  }

  size_t countByType(TenantId tenantId, SubaccountId subaccountId, CertificateType type) {
    return findByType(tenantId, subaccountId, type).length;
  }
  Certificate[] filterByType(Certificate[] certs, CertificateType type) {
    return certs.filter!(e => e.certificateType == type).array;
  }
  Certificate[] findByType(TenantId tenantId, SubaccountId subaccountId, CertificateType type) {
    return filterByType(findBySubaccount(tenantId, subaccountId), type);
  }
  void removeByType(TenantId tenantId, SubaccountId subaccountId, CertificateType type) {
    findByType(tenantId, subaccountId, type).each!(e => remove(e));
  }

  size_t countExpiring(TenantId tenantId, long beforeTimestamp) {
    return findExpiring(tenantId, beforeTimestamp).length;
  }
  Certificate[] filterExpiring(Certificate[] certs, long beforeTimestamp) {
    return certs.filter!(e => e.validTo > 0 && e.validTo <= beforeTimestamp).array;
  }

  Certificate[] findExpiring(TenantId tenantId, long beforeTimestamp) {
    return findByTenant(tenantId).filter!(e => e.validTo > 0 && e.validTo <= beforeTimestamp).array;
  }
  void removeExpiring(TenantId tenantId, long beforeTimestamp) {
    findExpiring(tenantId, beforeTimestamp).each!(e => remove(e));
  }

  
}
