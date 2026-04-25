/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.service_instance;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.service_instance;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying service instances.
interface IServiceInstanceRepository : ITenantRepository!(ServiceInstance, ServiceInstanceId) {
  
  bool existsByName(TenantId tenantId, SpaceId spaceId, string name);
  ServiceInstance findByName(TenantId tenantId, SpaceId spaceId, string name);
  void removeByName(TenantId tenantId, SpaceId spaceId, string name);
  
  size_t countBySpace(TenantId tenantId, SpaceId spaceId);
  ServiceInstance[] filterBySpace(TenantId tenantId, SpaceId spaceId);
  ServiceInstance[] findBySpace(TenantId tenantId, SpaceId spaceId);
  void removeBySpace(TenantId tenantId, SpaceId spaceId);

  size_t countByServiceName(TenantId tenantId, SpaceId spaceId, string serviceName);
  ServiceInstance[] filterByServiceName(TenantId tenantId, SpaceId spaceId, string serviceName);
  ServiceInstance[] findByServiceName(TenantId tenantId, SpaceId spaceId, string serviceName);
  void removeByServiceName(TenantId tenantId, SpaceId spaceId, string serviceName);

}
