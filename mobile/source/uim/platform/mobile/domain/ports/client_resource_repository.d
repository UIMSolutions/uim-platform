/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.client_resource_repository;

import uim.platform.mobile.domain.entities.client_resource;
import uim.platform.mobile.domain.types;

interface ClientResourceRepository {
  ClientResource findById(ClientResourceId id);
  ClientResource findByName(MobileAppId appId, string name);
  ClientResource[] findByApp(MobileAppId appId);
  ClientResource[] findByType(MobileAppId appId, ClientResourceType type);
  ClientResource[] findByTenant(TenantId tenantId);
  void save(ClientResource resource);
  void update(ClientResource resource);
  void remove(ClientResourceId id);
  long countByApp(MobileAppId appId);
}
