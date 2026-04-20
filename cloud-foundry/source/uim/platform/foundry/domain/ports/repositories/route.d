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
  bool existsByHostAndDomain(TenantId tenantId, string host, DomainId domainId);
  Route findByHostAndDomain(TenantId tenantId, string host, DomainId domainId);
  void removeByHostAndDomain(TenantId tenantId, string host, DomainId domainId);
  
  size_t countBySpace(TenantId tenantId, SpaceId spacetenantId);
  Route[] findBySpace(TenantId tenantId, SpaceId spacetenantId);
  void removeBySpace(TenantId tenantId, SpaceId spacetenantId);
  
  size_t countByDomain(TenantId tenantId, DomainId domaintenantId);
  Route[] findByDomain(TenantId tenantId, DomainId domaintenantId);
  void removeByDomain(TenantId tenantId, DomainId domaintenantId);
  
  size_t countByApp(TenantId tenantId, AppId apptenantId);
  Route[] findByApp(TenantId tenantId, AppId apptenantId);
  void removeByApp(TenantId tenantId, AppId apptenantId);
}
