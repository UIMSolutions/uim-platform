/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.service_instance_repository;

import uim.platform.html_repository.domain.entities.service_instance;
import uim.platform.html_repository.domain.types;

interface ServiceInstanceRepository {
  ServiceInstance findById(ServiceInstanceId id);
  ServiceInstance findByName(TenantId tenantId, string name);
  ServiceInstance[] findByTenant(TenantId tenantId);
  ServiceInstance[] findBySpace(SpaceId spaceId);
  ServiceInstance[] findByPlan(TenantId tenantId, ServicePlan plan);
  void save(ServiceInstance instance);
  void update(ServiceInstance instance);
  void remove(ServiceInstanceId id);
  long countByTenant(TenantId tenantId);
}
