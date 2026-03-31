module domain.ports.service_instance_repository;

import domain.entities.service_instance;
import domain.types;

/// Port: outgoing — service instance persistence.
interface ServiceInstanceRepository
{
    ServiceInstance findById(ServiceInstanceId id);
    ServiceInstance findByName(NamespaceId nsId, string name);
    ServiceInstance[] findByNamespace(NamespaceId nsId);
    ServiceInstance[] findByEnvironment(KymaEnvironmentId envId);
    ServiceInstance[] findByOffering(string offeringName);
    void save(ServiceInstance inst);
    void update(ServiceInstance inst);
    void remove(ServiceInstanceId id);
}
