module uim.platform.kyma.domain.ports.environment_repository;

import uim.platform.kyma.domain.entities.kyma_environment;
import uim.platform.kyma.domain.types;

/// Port: outgoing — Kyma environment persistence.
interface EnvironmentRepository
{
    KymaEnvironment findById(KymaEnvironmentId id);
    KymaEnvironment[] findByTenant(TenantId tenantId);
    KymaEnvironment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
    KymaEnvironment[] findByStatus(EnvironmentStatus status);
    void save(KymaEnvironment env);
    void update(KymaEnvironment env);
    void remove(KymaEnvironmentId id);
}
