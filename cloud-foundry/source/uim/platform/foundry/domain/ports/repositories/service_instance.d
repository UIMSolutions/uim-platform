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
  bool existsByName(SpaceId spacetenantId, id tenantId, string name);
  ServiceInstance findByName(SpaceId spacetenantId, id tenantId, string name);
  void removeByName(SpaceId spacetenantId, id tenantId, string name);
  
  size_t countBySpace(SpaceId spacetenantId, id tenantId);
  ServiceInstance[] findBySpace(SpaceId spacetenantId, id tenantId);
  void removeBySpace(SpaceId spacetenantId, id tenantId);

  size_t countByServiceName(SpaceId spacetenantId, id tenantId, string serviceName);
  ServiceInstance[] findByServiceName(SpaceId spacetenantId, id tenantId, string serviceName);
  void removeByServiceName(SpaceId spacetenantId, id tenantId, string serviceName);
}
