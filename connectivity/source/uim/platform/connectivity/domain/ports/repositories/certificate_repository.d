module uim.platform.connectivity.domain.ports.certificate_repository;

import uim.platform.connectivity.domain.entities.certificate;
import uim.platform.connectivity.domain.types;

/// Port: outgoing - certificate store persistence.
interface CertificateRepository
{
  bool existsId(CertificateId id);
  Certificate findById(CertificateId id);

  bool existsName(TenantId tenantId, string name);
  Certificate findByName(TenantId tenantId, string name);

  Certificate[] findByTenant(TenantId tenantId);
  Certificate[] findExpiring(TenantId tenantId, long now, uint withinDays);

  void save(Certificate cert);
  void update(Certificate cert);
  void remove(CertificateId id);
}
