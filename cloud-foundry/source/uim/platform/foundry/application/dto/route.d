module uim.platform.foundry.application.dto.route;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:

struct CreateRouteRequest {
  SpaceId spaceId;
  CfDomainId domainId;
  TenantId tenantId;
  RouteId routeId;

  string host;
  string path;
  int port;
  string protocol;
  UserId createdBy;
}

struct MapRouteRequest {
  RouteId routeId;
  AppId appId;
  TenantId tenantId;
}
