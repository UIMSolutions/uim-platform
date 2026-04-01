module uim.platform.abap_enviroment.infrastructure.persistence.memory.software_component_repo;

// import uim.platform.abap_enviroment.domain.types;
// import uim.platform.abap_enviroment.domain.entities.software_component;
// import uim.platform.abap_enviroment.domain.ports.software_component_repository;
// 
// import std.algorithm : filter;
// import std.array : array;

import uim.platform.abap_enviroment;
mixin(ShowModule!());
@safe:
class MemorySoftwareComponentRepository : SoftwareComponentRepository {
    private SoftwareComponent[SoftwareComponentId] store;

    SoftwareComponent* findById(SoftwareComponentId id) {
        if (id in store)
            return &store[id];
        return null;
    }

    SoftwareComponent[] findBySystem(SystemInstanceId systemId) {
        return store.byValue().filter!(e => e.systemInstanceId == systemId).array;
    }

    SoftwareComponent[] findByTenant(TenantId tenantId) {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    SoftwareComponent* findByName(SystemInstanceId systemId, string name) {
        foreach (ref e; store.byValue())
            if (e.systemInstanceId == systemId && e.name == name)
                return &store[e.id];
        return null;
    }

    void save(SoftwareComponent component) {
        store[component.id] = component;
    }

    void update(SoftwareComponent component) {
        store[component.id] = component;
    }

    void remove(SoftwareComponentId id) {
        store.remove(id);
    }
}
