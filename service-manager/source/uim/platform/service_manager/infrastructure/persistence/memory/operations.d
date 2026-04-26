module uim.platform.service_manager.infrastructure.persistence.memory.memory_operation_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryOperationRepository : TenantRepository!(Operation, OperationId), OperationRepository {

    // TODO: Implement methods for filtering by status and resource
}
