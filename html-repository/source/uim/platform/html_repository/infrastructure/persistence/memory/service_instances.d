/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.memory.service_instances;

import uim.platform.html_repository.domain.ports.repositories.service_instances;
import uim.platform.html_repository.domain.entities.service_instance;
import uim.platform.html_repository.domain.types;

class ServiceInstanceMemoryRepository : TenantRepository!(ServiceInstance, ServiceInstanceId), ServiceInstanceRepository {

  bool existsByName(TenantId tenantId, string name) {
    foreach (e; findAll) {
      if (e.tenantId == tenantId && e.name == name) return true;
    }
    return false;
  }

  ServiceInstance findByName(TenantId tenantId, string name) {
    foreach (e; findAll) {
      if (e.tenantId == tenantId && e.name == name) return e;
    }
    return ServiceInstance.init;
  }


  size_t countBySpace(SpaceId spaceId) {
    return findBySpace(spaceId).length;
  }
  ServiceInstance[] filterBySpace(ServiceInstance[] instances, SpaceId spaceId) {
    return instances.filter!(i => i.spaceId == spaceId).array;
  }
  ServiceInstance[] findBySpace(SpaceId spaceId) {
    return filterBySpace(findAll(), spaceId);
  }
  void removeBySpace(SpaceId spaceId) {
    findBySpace(spaceId).each!(i => remove(i.id));
  }

  size_t countByPlan(TenantId tenantId, ServicePlan plan) {
    return findByPlan(tenantId, plan).length;
  }
  ServiceInstance[] filterByPlan(ServiceInstance[] instances, TenantId tenantId, ServicePlan plan) {
    return instances.filter!(i => i.tenantId == tenantId && i.plan == plan).array;
  }
  ServiceInstance[] findByPlan(TenantId tenantId, ServicePlan plan) {
    return filterByPlan(findAll(), tenantId, plan);
  }
  void removeByPlan(TenantId tenantId, ServicePlan plan) {
    findByPlan(tenantId, plan).each!(i => remove(i.id));
  }

}
