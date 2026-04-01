module uim.platform.abap_enviroment.infrastructure.persistence.in_memory_software_component_repo;

import domain.types;
import domain.entities.software_component;
import domain.ports.software_component_repository;

import std.algorithm : filter;
import std.array : array;

class InMemorySoftwareComponentRepository : SoftwareComponentRepository
{
    private SoftwareComponent[SoftwareComponentId] store;

    SoftwareComponent* findById(SoftwareComponentId id)
    {
        if (auto p = id in store)
            return p;
        return null;
    }

    SoftwareComponent[] findBySystem(SystemInstanceId systemId)
    {
        return store.byValue().filter!(e => e.systemInstanceId == systemId).array;
    }

    SoftwareComponent[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    SoftwareComponent* findByName(SystemInstanceId systemId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.systemInstanceId == systemId && e.name == name)
                return &store[e.id];
        return null;
    }

    void save(SoftwareComponent component) { store[component.id] = component; }
    void update(SoftwareComponent component) { store[component.id] = component; }
    void remove(SoftwareComponentId id) { store.remove(id); }
}
