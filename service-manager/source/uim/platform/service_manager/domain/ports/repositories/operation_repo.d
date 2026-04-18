module uim.platform.service_manager.domain.ports.repositories.operation_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface OperationRepository {
    Operation[] findByTenant(TenantId tenantId);
    Operation* findById(TenantId tenantId, OperationId id);
    void save(Operation entity);
    void update(Operation entity);
    void remove(TenantId tenantId, OperationId id);
    ulong countByTenant(TenantId tenantId);
}
