/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.widgets;

  // import uim.platform.workzone.domain.types;
  // import uim.platform.workzone.domain.entities.widget;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface WidgetRepository : ITenantRepository!(Widget, WidgetId) {

  size_t countBySite(TenantId tenantId, SiteId siteId);
  Widget[] findBySite(TenantId tenantId, SiteId siteId);
  void removeBySite(TenantId tenantId, SiteId siteId);

}
