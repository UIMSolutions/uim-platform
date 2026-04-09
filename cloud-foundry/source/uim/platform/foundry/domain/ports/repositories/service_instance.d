/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.service_instance;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.service_instance;

/// Port for persisting and querying service instances.
interface IServiceInstanceRepository {
  ServiceInstance[] findBySpace(SpaceId spacetenantId, id tenantId);
  ServiceInstance* findById(ServiceInstanceId tenantId, id tenantId);
  ServiceInstance* findByName(SpaceId spacetenantId, id tenantId, string name);
  ServiceInstance[] findByServiceName(SpaceId spacetenantId, id tenantId, string serviceName);
  ServiceInstance[] findByTenant(TenantId tenantId);
  void save(ServiceInstance instance);
  void update(ServiceInstance instance);
  void remove(ServiceInstanceId tenantId, id tenantId);
}
