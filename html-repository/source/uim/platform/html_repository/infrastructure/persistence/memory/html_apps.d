/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.memory.html_app_repository;

import uim.platform.html_repository.domain.ports.repositories.html_apps;
import uim.platform.html_repository.domain.entities.html_app;
import uim.platform.html_repository.domain.types;

class HtmlAppMemoryRepository : TenantRepository!(HtmlApp, HtmlAppId), HtmlAppRepository {


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


  size_t countByServiceInstance(ServiceInstanceId instanceId) {
    size_t count = 0;
    foreach (e; findAll) {
      if (e.serviceInstanceId == instanceId) count++;
    }
    return count;
  }
}
