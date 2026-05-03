module uim.platform.service_manager.infrastructure.persistence.memory.service_instances;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServiceInstanceRepository : TenantRRepository!(ServiceInstance, ServiceInstanceId), ServiceInstanceRepository {

    // TODO:
}
