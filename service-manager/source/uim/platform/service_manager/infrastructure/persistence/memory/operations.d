module uim.platform.service_manager.infrastructure.persistence.memory.operations;

import uim.platform.service_manager;

// mixin(ShowModule!());

@safe:

class MemoryOperationRepository : TentRepository!(Operation, OperationId), OperationRepository {

    // #region ByOperationType
    size_t countByOperationType(TenantId tenantId, OperationType type) {
        return this.findByOperationType(tenantId, type).length;
    }

    Operation[] filterByOperationType(Operation[] operations, OperationType type) {
        return operations.filter!(op => op.type == type).array;
    }

    Operation[] findByOperationType(TenantId tenantId, OperationType type) {
        return this.filterByOperationType(this.findByTenant(tenantId), type);
    }

    void removeByOperationType(TenantId tenantId, OperationType type) {
        this.removeAll(this.findByOperationType(tenantId, type));
    }
    // #endregion ByOperationType

    // #region ByOperationStatus
    size_t countByOperationStatus(TenantId tenantId, OperationStatus status) {
        return this.findByOperationStatus(tenantId, status).length;
    }

    Operation[] filterByOperationStatus(Operation[] operations, OperationStatus status) {
        return operations.filter!(op => op.status == status).array;
    }

    Operation[] findByOperationStatus(TenantId tenantId, OperationStatus status) {
        return this.filterByOperationStatus(this.findByTenant(tenantId), status);
    }

    void removeByOperationStatus(TenantId tenantId, OperationStatus status) {
        this.removeAll(this.findByOperationStatus(tenantId, status));
    }
    // #endregion ByOperationStatus
}
