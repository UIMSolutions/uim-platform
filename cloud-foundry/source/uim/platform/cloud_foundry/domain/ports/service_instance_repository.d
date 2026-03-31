module domain.ports.service_instance_repository;

import domain.types;
import domain.entities.service_instance;

/// Port for persisting and querying service instances.
interface ServiceInstanceRepository
{
  ServiceInstance[] findBySpace(SpaceId spaceId, TenantId tenantId);
  ServiceInstance* findById(ServiceInstanceId id, TenantId tenantId);
  ServiceInstance* findByName(SpaceId spaceId, TenantId tenantId, string name);
  ServiceInstance[] findByServiceName(SpaceId spaceId, TenantId tenantId, string serviceName);
  ServiceInstance[] findByTenant(TenantId tenantId);
  void save(ServiceInstance instance);
  void update(ServiceInstance instance);
  void remove(ServiceInstanceId id, TenantId tenantId);
}
