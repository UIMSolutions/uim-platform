module uim.platform.destination.infrastructure.persistence.memory.certificate_repo;

import uim.platform.destination.domain.types;
import uim.platform.destination.domain.entities.certificate;
import uim.platform.destination.domain.ports.certificate_repository;

// import std.algorithm : filter;
// import std.array : array;

class MemoryCertificateRepository : CertificateRepository
{
  private Certificate[CertificateId] store;

  Certificate findById(CertificateId id)
  {
    if (auto p = id in store)
      return *p;
    return Certificate.init;
  }

  Certificate findByName(TenantId tenantId, SubaccountId subaccountId, string name)
  {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.subaccountId == subaccountId && e.name == name)
        return e;
    return Certificate.init;
  }

  Certificate[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  Certificate[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.subaccountId == subaccountId).array;
  }

  Certificate[] findByType(TenantId tenantId, SubaccountId subaccountId, CertificateType type)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.subaccountId == subaccountId && e.certificateType == type).array;
  }

  Certificate[] findExpiring(TenantId tenantId, long beforeTimestamp)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.validTo > 0
        && e.validTo <= beforeTimestamp).array;
  }

  void save(Certificate cert)
  {
    store[cert.id] = cert;
  }

  void update(Certificate cert)
  {
    store[cert.id] = cert;
  }

  void remove(CertificateId id)
  {
    store.remove(id);
  }
}
