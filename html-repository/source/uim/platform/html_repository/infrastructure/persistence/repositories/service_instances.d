/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.repositories.service_instances;

// import uim.platform.html_repository.domain.ports.repositories.service_instances;
// import uim.platform.html_repository.domain.entities.service_instance;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class ServiceInstanceRepository : TenantRepository!(ServiceInstance, ServiceInstanceId), IServiceInstanceRepository {

  bool existsByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId)) {
      if (e.tenantId == tenantId && e.name == name) return true;
    }
    return false;
  }

  ServiceInstance findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId)) {
      if (e.tenantId == tenantId && e.name == name) return e;
    }
    return ServiceInstance.init;
  }

  void removeByName(TenantId tenantId, string name) {
    ServiceInstance instance = findByName(tenantId, name);
    if (instance.id != ServiceInstanceId.init) {
      remove(instance);
    }
  }

  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }
  ServiceInstance[] filterBySpace(ServiceInstance[] instances, SpaceId spaceId) {
    return instances.filter!(i => i.spaceId == spaceId).array;
  }
  ServiceInstance[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }
  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(i => remove(i));
  }

  size_t countByPlan(TenantId tenantId, ServicePlan plan) {
    return findByPlan(tenantId, plan).length;
  }
  ServiceInstance[] filterByPlan(ServiceInstance[] instances, ServicePlan plan) {
    return instances.filter!(i => i.plan == plan).array;
  }
  ServiceInstance[] findByPlan(TenantId tenantId, ServicePlan plan) {
    return filterByPlan(findByTenant(tenantId), plan);
  }
  void removeByPlan(TenantId tenantId, ServicePlan plan) {
    findByPlan(tenantId, plan).each!(i => remove(i));
  }

}
