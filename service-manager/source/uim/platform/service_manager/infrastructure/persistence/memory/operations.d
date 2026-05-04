module uim.platform.service_manager.infrastructure.persistence.memory.operations;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryOperationRepository : TenantRepository!(Operation, OperationId), OperationRepository {

    size_t countByOperationType(OperationType type) {
        return this.findByOperationType(type).length;
    }

    Operation[] filterByOperationType(Operation[] operations, OperationType type) {
        return operations.filter!(op => op.type == type).array;
    }

    Operation[] findByOperationType(OperationType type) {
        return this.filterByOperationType(this.findAll(), type);
    }

    void removeByOperationType(OperationType type) {
        this.removeAll(this.findByOperationType(type));
    }

    size_t countByOperationStatus(OperationStatus status) {
        return this.findByOperationStatus(status).length;
    }

    Operation[] filterByOperationStatus(Operation[] operations, OperationStatus status) {
        return operations.filter!(op => op.status == status).array;
    }

    Operation[] findByOperationStatus(OperationStatus status) {
        return this.filterByOperationStatus(this.findAll(), status);
    }

    void removeByOperationStatus(OperationStatus status) {
        this.removeAll(this.findByOperationStatus(status));
    }

}
