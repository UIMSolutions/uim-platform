module uim.platform.service_manager.domain.ports.repositories.operations;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface OperationRepository : ITenantRepository!(Operation, OperationId) {

    size_t countByOperationType(OperationType type);
    Operation[] filterByOperationType(Operation[] operations, OperationType type);
    Operation[] findByOperationType(OperationType type);
    void removeByOperationType(OperationType type);

    size_t countByOperationStatus(OperationStatus status);
    Operation[] filterByOperationStatus(Operation[] operations, OperationStatus status);
    Operation[] findByOperationStatus(OperationStatus status);
    void removeByOperationStatus(OperationStatus status);

}
