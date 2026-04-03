module uim.platform.xyz.domain.ports.application_repository;

import uim.platform.xyz.domain.entities.application;
import uim.platform.xyz.domain.types;

/// Port: outgoing — external application connectivity persistence.
interface ApplicationRepository
{
    Application findById(ApplicationId id);
    Application findByName(KymaEnvironmentId envId, string name);
    Application[] findByEnvironment(KymaEnvironmentId envId);
    Application[] findByStatus(AppConnectivityStatus status);
    Application[] findByTenant(TenantId tenantId);
    void save(Application app);
    void update(Application app);
    void remove(ApplicationId id);
}
