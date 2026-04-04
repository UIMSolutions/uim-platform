/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.route;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.route;

/// Port for persisting and querying routes.
interface IRouteRepository {
  Route[] findBySpace(SpaceId spaceId, TenantId tenantId);
  Route* findById(RouteId id, TenantId tenantId);
  Route* findByHostAndDomain(TenantId tenantId, string host, DomainId domainId);
  Route[] findByDomain(DomainId domainId, TenantId tenantId);
  Route[] findByApp(AppId appId, TenantId tenantId);
  Route[] findByTenant(TenantId tenantId);
  void save(Route route);
  void update(Route route);
  void remove(RouteId id, TenantId tenantId);
}
