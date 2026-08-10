/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.repositories.html_apps;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class HtmlAppRepository : TenantRepository!(HtmlApp, HtmlAppId), IHtmlAppRepository {

  size_t countByName(TenantId tenantId, string name) {
    return findByName(tenantId, name);
  }

  HtmlApp[] filterByName(HtmlApp[] apps, string name) {
    return apps.filter!(a => a.name == name).array;
  }

  HtmlApp[] findByName(TenantId tenantId, string name) {
    return filterByName(findByTenant(tenantId), name);
  }

  void removeByName(TenantId tenantId, string name) {
    findByName(tenantId, name).each!(e => remove(e));
  }

  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }
  HtmlApp[] filterBySpace(HtmlApp[] apps, SpaceId spaceId) {
    return apps.filter!(a => a.spaceId == spaceId).array;
  }
  HtmlApp[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }
  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(a => remove(a));
  }

  size_t countByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return findByServiceInstance(tenantId, instanceId).length;
  }
  HtmlApp[] filterByServiceInstance(HtmlApp[] apps, ServiceInstanceId instanceId) {
    return apps.filter!(a => a.serviceInstanceId == instanceId).array;
  }
  HtmlApp[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return filterByServiceInstance(findByTenant(tenantId), instanceId);
  }
  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    findByServiceInstance(tenantId, instanceId).each!(a => remove(a));
  }

  size_t countPublic(TenantId tenantId) {
    return findPublic(tenantId).length;
  }
  HtmlApp[] filterPublic(HtmlApp[] apps) {
    return apps.filter!(a => a.visibility == AppVisibility.public_).array;
  }
  HtmlApp[] findPublic(TenantId tenantId) {
    return filterPublic(findByTenant(tenantId));
  }
  void removePublic(TenantId tenantId) {
    findPublic(tenantId).each!(a => remove(a));
  }

}
