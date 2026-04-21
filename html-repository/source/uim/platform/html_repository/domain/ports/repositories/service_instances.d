/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.repositories.service_instances;

// import uim.platform.html_repository.domain.entities.service_instance;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
interface ServiceInstanceRepository : ITenantRepository!(ServiceInstance, ServiceInstanceId) {

  bool existsByName(TenantId tenantId, string name);
  ServiceInstance findByName(TenantId tenantId, string name);  
  void removeByName(TenantId tenantId, string name);

  size_t countBySpace(SpaceId spaceId);
  ServiceInstance[] findBySpace(SpaceId spaceId);
  void removeBySpace(SpaceId spaceId);

  size_t countByPlan(TenantId tenantId, ServicePlan plan);
  ServiceInstance[] findByPlan(TenantId tenantId, ServicePlan plan);
  void removeByPlan(TenantId tenantId, ServicePlan plan);

}
