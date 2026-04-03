module uim.platform.xyz.domain.ports.environment_repository;

import uim.platform.xyz.domain.entities.kyma_environment;
import uim.platform.xyz.domain.types;

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
