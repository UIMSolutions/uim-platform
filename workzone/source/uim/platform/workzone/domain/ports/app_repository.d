module uim.platform.xyz.domain.ports.app_repository;

import domain.types;
import domain.entities.app_registration;

interface AppRepository
{
    AppRegistration[] findByTenant(TenantId tenantId);
    AppRegistration* findById(AppId id, TenantId tenantId);
    AppRegistration[] findByStatus(AppStatus status, TenantId tenantId);
    void save(AppRegistration app);
    void update(AppRegistration app);
    void remove(AppId id, TenantId tenantId);
}
