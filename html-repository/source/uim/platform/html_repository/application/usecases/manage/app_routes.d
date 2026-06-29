/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.manage.app_routes;
// import uim.platform.html_repository.domain.ports.repositories.app_routes;
// import uim.platform.html_repository.domain.entities.app_route;
// import uim.platform.html_repository.domain.services.deployment_validator;
// import uim.platform.html_repository.domain.types;
// import uim.platform.html_repository.application.dto;

import uim.platform.html_repository;

// mixin(ShowModule!());

@safe:


class ManageAppRoutesUseCase { // TODO: UIMUseCase {
    private AppRouteRepository repo;

    this(AppRouteRepository repo) {
        this.repo = repo;
    }

    CommandResult createAppRoute(CreateAppRouteRequest request) {
        if (!DeploymentValidator.validatePathPrefix(request.pathPrefix))
            return CommandResult(false, "", "Invalid path prefix");

        AppRoute route;
        route.initEntity(request.tenantId, request.createdBy);
        with (route) {
            appId = request.appId;
            pathPrefix = request.pathPrefix;
            targetUrl = request.targetUrl;
            description = request.description;
            status = RouteStatus.active;
            
            /* versionId = request.versionId;
            pathPrefix = request.pathPrefix;
            targetPath = request.targetPath;
            authRequired = request.authRequired;
            cacheEnabled = request.cacheEnabled;
            */
        }

        repo.save(route);
        return CommandResult(true, route.id.value, "");
    }

    CommandResult updateAppRoute(AppRouteId id, UpdateAppRouteRequest request) {
        auto route = repo.findById(tenantId, id);
        if (route.isNull)
            return CommandResult(false, "", "Route not found");

        if (request.pathPrefix.length > 0)
            route.pathPrefix = request.pathPrefix;
        if (request.targetPath.length > 0)
            route.targetPath = request.targetPath;
        route.authRequired = request.authRequired;
        route.cacheEnabled = request.cacheEnabled;
        route.updatedAt = currentTimestamp();
        route.updatedBy = request.updatedBy;

        repo.update(route);
        return CommandResult(true, route.id.value, "");
    }

    AppRoute getAppRoute(AppRouteId id) {
        return repo.findById(tenantId, id);
    }

    AppRoute[] listAppRoutes(HtmlAppId appId) {
        return repo.findByApp(appId);
    }

    AppRoute[] listAppRoutes(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult deleteAppRoute(AppRouteId id) {
        auto route = repo.findById(tenantId, id);
        if (route.isNull)          
            return CommandResult(false, "", "Route not found");

        repo.remove(route);
        return CommandResult(true, route.id.value, "");
    }

    size_t countAppRoutesByApp(HtmlAppId appId) {
        return repo.countByApp(appId);
    }

}
