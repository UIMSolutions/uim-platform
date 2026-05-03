module uim.platform.service_manager.infrastructure.persistence.memory.memory_service_binding_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {

// TODO

}
