module infrastructure.persistence.in_memory_service_instance_repo;

import domain.types;
import domain.entities.service_instance;
import domain.ports.service_instance_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryServiceInstanceRepository : ServiceInstanceRepository
{
    private ServiceInstance[ServiceInstanceId] store;

    ServiceInstance findById(ServiceInstanceId id)
    {
        if (auto p = id in store)
            return *p;
        return ServiceInstance.init;
    }

    ServiceInstance findByName(NamespaceId nsId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.namespaceId == nsId && e.name == name)
                return e;
        return ServiceInstance.init;
    }

    ServiceInstance[] findByNamespace(NamespaceId nsId)
    {
        return store.byValue().filter!(e => e.namespaceId == nsId).array;
    }

    ServiceInstance[] findByEnvironment(KymaEnvironmentId envId)
    {
        return store.byValue().filter!(e => e.environmentId == envId).array;
    }

    ServiceInstance[] findByOffering(string offeringName)
    {
        return store.byValue().filter!(e => e.serviceOfferingName == offeringName).array;
    }

    void save(ServiceInstance inst) { store[inst.id] = inst; }
    void update(ServiceInstance inst) { store[inst.id] = inst; }
    void remove(ServiceInstanceId id) { store.remove(id); }
}
