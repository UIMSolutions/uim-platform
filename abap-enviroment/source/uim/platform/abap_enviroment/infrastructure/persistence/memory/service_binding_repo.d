module uim.platform.abap_enviroment.infrastructure.persistence.memory.service_binding_repo;

// import uim.platform.abap_enviroment.domain.types;
// import uim.platform.abap_enviroment.domain.entities.service_binding;
// import uim.platform.abap_enviroment.domain.ports.service_binding_repository;
// 
// import std.algorithm : filter;
// import std.array : array;

import uim.platform.abap_enviroment;
mixin(ShowModule!());
@safe:
class InMemoryServiceBindingRepository : ServiceBindingRepository {
    private ServiceBinding[ServiceBindingId] store;

    ServiceBinding* findById(ServiceBindingId id) {
        if (auto p = id in store)
            return p;
        return null;
    }

    ServiceBinding[] findBySystem(SystemInstanceId systemId) {
        return store.byValue().filter!(e => e.systemInstanceId == systemId).array;
    }

    ServiceBinding[] findByTenant(TenantId tenantId) {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    ServiceBinding[] findByType(SystemInstanceId systemId, BindingType bindingType) {
        return store.byValue()
            .filter!(e => e.systemInstanceId == systemId && e.bindingType == bindingType)
            .array;
    }

    void save(ServiceBinding binding) {
        store[binding.id] = binding;
    }

    void update(ServiceBinding binding) {
        store[binding.id] = binding;
    }

    void remove(ServiceBindingId id) {
        store.remove(id);
    }
}
