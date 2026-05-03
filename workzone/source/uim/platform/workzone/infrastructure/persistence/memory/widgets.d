/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.widgets;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.widget;
// import uim.platform.workzone.domain.ports.repositories.widgets;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class MemoryWidgetRepository : TenantRepository!(Widget, WidgetId), WidgetRepository {

  size_t countByPage(TenantId tenantId, WorkpageId pageId) {
    return findByPage(tenantId, pageId).length;
  }
  Widget[] findByPage(TenantId tenantId, WorkpageId pageId) {
    return findAll().filter!(w => w.tenantId == tenantId && w.pageId == pageId).array;
  }
  void removeByPage(TenantId tenantId, WorkpageId pageId) {
    findByPage(tenantId, pageId).each!(w => remove(w));
  }

  size_t countBySite(TenantId tenantId, SiteId siteId) {
    return findBySite(tenantId, siteId).length;
  }
   Widget[] findBySite(TenantId tenantId, SiteId siteId) {
    return findAll().filter!(w => w.tenantId == tenantId && w.siteId == siteId).array;
  }
  void removeBySite(TenantId tenantId, SiteId siteId) {
    findBySite(tenantId, siteId).each!(w => remove(w));
  }

}
