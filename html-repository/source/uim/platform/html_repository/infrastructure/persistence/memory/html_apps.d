/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.memory.html_app_repository;

import uim.platform.html_repository.domain.ports.repositories.html_apps;
import uim.platform.html_repository.domain.entities.html_app;
import uim.platform.html_repository.domain.types;

class HtmlAppMemoryRepository : HtmlAppRepository {
  private HtmlApp[] store;

  HtmlApp findById(HtmlAppId id) {
    foreach (e; findAll) {
      if (e.id == id) return e;
    }
    return HtmlApp.init;
  }

  HtmlApp findByName(TenantId tenantId, string name) {
    foreach (e; findAll) {
      if (e.tenantId == tenantId && e.name == name) return e;
    }
    return HtmlApp.init;
  }

  HtmlApp[] findByTenant(TenantId tenantId) {
    HtmlApp[] result;
    foreach (e; findAll) {
      if (e.tenantId == tenantId) result ~= e;
    }
    return result;
  }

  HtmlApp[] findBySpace(SpaceId spaceId) {
    HtmlApp[] result;
    foreach (e; findAll) {
      if (e.spaceId == spaceId) result ~= e;
    }
    return result;
  }

  HtmlApp[] findByServiceInstance(ServiceInstanceId instanceId) {
    HtmlApp[] result;
    foreach (e; findAll) {
      if (e.serviceInstanceId == instanceId) result ~= e;
    }
    return result;
  }

  HtmlApp[] findPublic(TenantId tenantId) {
    HtmlApp[] result;
    foreach (e; findAll) {
      if (e.tenantId == tenantId && e.visibility == AppVisibility.public_) result ~= e;
    }
    return result;
  }

  void save(HtmlApp app) {
    store ~= app;
  }

  void update(HtmlApp app) {
    foreach (i, e; store) {
      if (e.id == app.id) {
        store[i] = app;
        return;
      }
    }
  }

  void remove(HtmlAppId id) {
    HtmlApp[] result;
    foreach (e; findAll) {
      if (e.id != id) result ~= e;
    }
    store = result;
  }

  size_t countByTenant(TenantId tenantId) {
    size_t count = 0;
    foreach (e; findAll) {
      if (e.tenantId == tenantId) count++;
    }
    return count;
  }

  size_t countByServiceInstance(ServiceInstanceId instanceId) {
    size_t count = 0;
    foreach (e; findAll) {
      if (e.serviceInstanceId == instanceId) count++;
    }
    return count;
  }
}
