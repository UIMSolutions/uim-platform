module uim.platform.service_manager.domain.ports.repositories.operations;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface OperationRepository : ITenantRepository!(Operation, OperationId) {

    size_t countByOperationType(TenantId tenantId, OperationType type);
    Operation[] findByOperationType(TenantId tenantId, OperationType type);
    void removeByOperationType(TenantId tenantId, OperationType type);

    size_t countByOperationStatus(TenantId tenantId, OperationStatus status);
    Operation[] findByOperationStatus(TenantId tenantId, OperationStatus status);
    void removeByOperationStatus(TenantId tenantId, OperationStatus status);

}
