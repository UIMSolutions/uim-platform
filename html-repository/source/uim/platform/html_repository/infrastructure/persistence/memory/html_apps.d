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


  size_t countBySpace(SpaceId spaceId) {
    return findBySpace(spaceId).length;
  }
  HtmlApp[] filterBySpace(HtmlApp[] apps, SpaceId spaceId) {
    return apps.filter!(a => a.spaceId == spaceId).array;
  }
  HtmlApp[] findBySpace(SpaceId spaceId) {
    return filterBySpace(findAll(), spaceId);
  }
  void removeBySpace(SpaceId spaceId) {
    findBySpace(spaceId).each!(a => remove(a));
  }

  size_t countByServiceInstance(ServiceInstanceId instanceId) {
    return findByServiceInstance(instanceId).length;
  }
  HtmlApp[] filterByServiceInstance(HtmlApp[] apps, ServiceInstanceId instanceId) {
    return apps.filter!(a => a.serviceInstanceId == instanceId).array;
  }
  HtmlApp[] findByServiceInstance(ServiceInstanceId instanceId) {
    return filterByServiceInstance(findAll(), instanceId);
  }
  void removeByServiceInstance(ServiceInstanceId instanceId) {
    findByServiceInstance(instanceId).each!(a => remove(a));
  }

  size_t countPublicByTenant(TenantId tenantId) {
    return findPublic(tenantId).length;
  }
  HtmlApp[] filterPublic(HtmlApp[] apps, TenantId tenantId) {
    return apps.filter!(a => a.tenantId == tenantId && a.visibility == AppVisibility.public_).array;
  }
  HtmlApp[] findPublic(TenantId tenantId) {
    return filterPublic(findAll(), tenantId);
  }
  void removePublic(TenantId tenantId) {
    findPublic(tenantId).each!(a => remove(a));
  }

}
