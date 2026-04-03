module uim.platform.foundry.domain.ports.route;

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
