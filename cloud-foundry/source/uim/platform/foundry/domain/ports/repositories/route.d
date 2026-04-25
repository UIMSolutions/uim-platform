/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.route;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.route;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying routes.
interface IRouteRepository : ITenantRepository!(Route, RouteId) {

  bool existsByHostAndDomain(TenantId tenantId, string host, CfDomainId domainId);
  Route findByHostAndDomain(TenantId tenantId, string host, CfDomainId domainId);
  void removeByHostAndDomain(TenantId tenantId, string host, CfDomainId domainId);
  
  size_t countBySpace(TenantId tenantId, SpaceId spaceId);
  Route[] filterBySpace(Route[] routes, SpaceId spaceId);
  Route[] findBySpace(TenantId tenantId, SpaceId spaceId);
  void removeBySpace(TenantId tenantId, SpaceId spaceId);
  
  size_t countByDomain(TenantId tenantId, CfDomainId domainId);
  Route[] filterByDomain(Route[] routes, CfDomainId domainId);
  Route[] findByDomain(TenantId tenantId, CfDomainId domainId);
  void removeByDomain(TenantId tenantId, CfDomainId domainId);
  
  size_t countByApp(TenantId tenantId, AppId appId);
  Route[] filterByApp(Route[] routes, AppId appId);
  Route[] findByApp(TenantId tenantId, AppId appId);
  void removeByApp(TenantId tenantId, AppId appId);
  
}
