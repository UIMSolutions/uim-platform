/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.client_resources;

import uim.platform.mobile.domain.entities.client_resource;
import uim.platform.mobile.domain.types;

interface ClientResourceRepository : ITenantRepository!(ClientResource, ClientResourceId) {

  bool existsByName(MobileAppId appId, string name);
  ClientResource findByName(MobileAppId appId, string name);
  void removeByName(MobileAppId appId, string name);

  size_t countByApp(MobileAppId appId);
  ClientResource[] findByApp(MobileAppId appId);
  void removeByApp(MobileAppId appId);

  size_t countByType(MobileAppId appId, ClientResourceType type);
  ClientResource[] findByType(MobileAppId appId, ClientResourceType type);
  void removeByType(MobileAppId appId, ClientResourceType type);

}
