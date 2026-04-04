/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.memory.service_instance_repository;

import uim.platform.html_repository.domain.ports.service_instance_repository;
import uim.platform.html_repository.domain.entities.service_instance;
import uim.platform.html_repository.domain.types;

class ServiceInstanceMemoryRepository : ServiceInstanceRepository {
  private ServiceInstance[] store;

  ServiceInstance findById(ServiceInstanceId id) {
    foreach (e; store) {
      if (e.id == id) return e;
    }
    return ServiceInstance.init;
  }

  ServiceInstance findByName(TenantId tenantId, string name) {
    foreach (e; store) {
      if (e.tenantId == tenantId && e.name == name) return e;
    }
    return ServiceInstance.init;
  }

  ServiceInstance[] findByTenant(TenantId tenantId) {
    ServiceInstance[] result;
    foreach (e; store) {
      if (e.tenantId == tenantId) result ~= e;
    }
    return result;
  }

  ServiceInstance[] findBySpace(SpaceId spaceId) {
    ServiceInstance[] result;
    foreach (e; store) {
      if (e.spaceId == spaceId) result ~= e;
    }
    return result;
  }

  ServiceInstance[] findByPlan(TenantId tenantId, ServicePlan plan) {
    ServiceInstance[] result;
    foreach (e; store) {
      if (e.tenantId == tenantId && e.plan == plan) result ~= e;
    }
    return result;
  }

  void save(ServiceInstance instance) {
    store ~= instance;
  }

  void update(ServiceInstance instance) {
    foreach (i, e; store) {
      if (e.id == instance.id) {
        store[i] = instance;
        return;
      }
    }
  }

  void remove(ServiceInstanceId id) {
    ServiceInstance[] result;
    foreach (e; store) {
      if (e.id != id) result ~= e;
    }
    store = result;
  }

  long countByTenant(TenantId tenantId) {
    long count = 0;
    foreach (e; store) {
      if (e.tenantId == tenantId) count++;
    }
    return count;
  }
}
