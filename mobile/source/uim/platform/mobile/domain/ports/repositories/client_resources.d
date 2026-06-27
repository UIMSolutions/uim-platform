/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.client_resources;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

interface ClientResourceRepository : ITentRepository!(ClientResource, ClientResourceId) {

  bool existsByName(TenantId tenantId, MobileAppId appId, string name);
  ClientResource findByName(TenantId tenantId, MobileAppId appId, string name);
  void removeByName(TenantId tenantId, MobileAppId appId, string name);

  size_t countByApp(TenantId tenantId, MobileAppId appId);
  ClientResource[] findByApp(TenantId tenantId,   MobileAppId appId);
  void removeByApp(TenantId tenantId, MobileAppId appId);

  size_t countByType(TenantId tenantId, MobileAppId appId, ClientResourceType type);
  ClientResource[] findByType(TenantId tenantId, MobileAppId appId, ClientResourceType type);
  void removeByType(TenantId tenantId, MobileAppId appId, ClientResourceType type);

}
