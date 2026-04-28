module uim.platform.foundry.application.dto.route;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:

struct CreateRouteRequest {
  SpaceId spaceId;
  CfDomainId domainId;
  TenantId tenantId;
  string host;
  string path;
  int port;
  RouteProtocol protocol;
  string createdBy;
}

struct MapRouteRequest {
  RouteId routeId;
  AppId appId;
  TenantId tenantId;
}
