/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.usecases.app_routes;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:

interface IManageAppRoutesUseCase {

    UsecaseResult createAppRoute(CreateAppRouteRequest request);

    UsecaseResult updateAppRoute(UpdateAppRouteRequest request);

    AppRoute getAppRoute(TenantId tenantId, AppRouteId routeId);

    AppRoute[] listAppRoutes(TenantId tenantId, HtmlAppId appId);

    AppRoute[] listAppRoutes(TenantId tenantId);

    UsecaseResult deleteAppRoute(TenantId tenantId, AppRouteId routeId);

    size_t countAppRoutes(TenantId tenantId, HtmlAppId appId);

}
