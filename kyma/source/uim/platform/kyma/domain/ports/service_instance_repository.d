module uim.platform.xyz.domain.ports.service_instance_repository;

import uim.platform.xyz.domain.entities.service_instance;
import uim.platform.xyz.domain.types;

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
