module uim.platform.connectivity.domain.ports.certificate_repository;

import domain.entities.certificate;
import domain.types;

/// Port: outgoing - certificate store persistence.
interface CertificateRepository
{
    Certificate findById(CertificateId id);
    Certificate findByName(TenantId tenantId, string name);
    Certificate[] findByTenant(TenantId tenantId);
    Certificate[] findExpiring(TenantId tenantId, long now, uint withinDays);
    void save(Certificate cert);
    void update(Certificate cert);
    void remove(CertificateId id);
}
