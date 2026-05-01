/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.manage.app_routes;

import uim.platform.html_repository.domain.ports.repositories.app_routes;
import uim.platform.html_repository.domain.entities.app_route;
import uim.platform.html_repository.domain.services.deployment_validator;
import uim.platform.html_repository.domain.types;
import uim.platform.html_repository.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageAppRoutesUseCase { // TODO: UIMUseCase {
    private AppRouteRepository repo;

    this(AppRouteRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateAppRouteRequest request) {
        if (!DeploymentValidator.validatePathPrefix(request.pathPrefix))
            return CommandResult(false, "", "Invalid path prefix");

        AppRoute route;
        with (route) {
            id = randomUUID();
            tenantId = request.tenantId;
            appId = request.appId;
            pathPrefix = request.pathPrefix;
            targetUrl = request.targetUrl;
            description = request.description;
            status = RouteStatus.active;
            createdAt = currentTimestamp();
            updatedAt = createdAt;
            createdBy = request.createdBy;
            updatedBy = request.createdBy;
            
            /* versionId = request.versionId;
            pathPrefix = request.pathPrefix;
            targetPath = request.targetPath;
            authRequired = request.authRequired;
            cacheEnabled = request.cacheEnabled;
            */
        }

        repo.save(route);
        return CommandResult(true, route.id, "");
    }

    CommandResult update(string id, UpdateAppRouteRequest request) {
        return update(AppRouteId(id), request);
    }

    CommandResult update(AppRouteId id, UpdateAppRouteRequest request) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Route not found");

        auto route = repo.findById(id);
        if (request.pathPrefix.length > 0)
            route.pathPrefix = request.pathPrefix;
        if (request.targetPath.length > 0)
            route.targetPath = request.targetPath;
        route.authRequired = request.authRequired;
        route.cacheEnabled = request.cacheEnabled;
        route.updatedAt = currentTimestamp();
        route.updatedBy = request.updatedBy;

        repo.update(route);
        return CommandResult(true, route.id, "");
    }

    AppRoute getById(AppRouteId id) {
        return repo.findById(id);
    }

    AppRoute[] listByApp(HtmlAppId appId) {
        return repo.findByApp(appId);
    }

    AppRoute[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    void remove(AppRouteId id) {
        repo.removeById(id);
    }

    size_t countByApp(HtmlAppId appId) {
        return repo.countByApp(appId);
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;

        return Clock.currStdTime();
    }
}
