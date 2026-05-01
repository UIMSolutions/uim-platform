/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.entities.app_route;

// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
struct AppRoute {
  AppRouteId id;
  TenantId tenantId;
  HtmlAppId appId;
  string pathPrefix;        // URL path prefix e.g. "/myapp"
  string targetUrl;         // target backend URL for proxying
  string description;
  RouteStatus status;
  long createdAt;
  long updatedAt;
  UserId createdBy;
  UserId updatedBy;
}
