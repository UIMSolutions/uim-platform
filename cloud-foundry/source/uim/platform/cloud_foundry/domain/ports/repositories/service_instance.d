module uim.platform.cloud_foundry.domain.ports.service_instance;

import uim.platform.cloud_foundry.domain.types;
import uim.platform.cloud_foundry.domain.entities.service_instance;

/// Port for persisting and querying service instances.
interface ServiceInstanceRepository {
  ServiceInstance[] findBySpace(SpaceId spaceId, TenantId tenantId);
  ServiceInstance* findById(ServiceInstanceId id, TenantId tenantId);
  ServiceInstance* findByName(SpaceId spaceId, TenantId tenantId, string name);
  ServiceInstance[] findByServiceName(SpaceId spaceId, TenantId tenantId, string serviceName);
  ServiceInstance[] findByTenant(TenantId tenantId);
  void save(ServiceInstance instance);
  void update(ServiceInstance instance);
  void remove(ServiceInstanceId id, TenantId tenantId);
}
