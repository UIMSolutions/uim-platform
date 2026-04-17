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

class ManageAppRoutesUseCase : UIMUseCase {
    private AppRouteRepository repo;

    this(AppRouteRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateAppRouteRequest r) {
        if (!DeploymentValidator.validatePathPrefix(r.pathPrefix))
            return CommandResult(false, "", "Invalid path prefix");

        AppRoute route;
        route.id = randomUUID();
        route.tenantId = r.tenantId;
        route.appId = r.appId;
        route.versionId = r.versionId;
        route.pathPrefix = r.pathPrefix;
        route.targetPath = r.targetPath;
        route.authRequired = r.authRequired;
        route.cacheEnabled = r.cacheEnabled;
        route.status = RouteStatus.active;
        route.createdAt = currentTimestamp();
        route.updatedAt = route.createdAt;
        route.createdBy = r.createdBy;
        route.modifiedBy = r.createdBy;

        repo.save(route);
        return CommandResult(true, route.id, "");
    }

    CommandResult update(AppRouteId id, UpdateAppRouteRequest r) {
        auto route = repo.findById(id);
        if (route.id.isEmpty)
            return CommandResult(false, "", "Route not found");

        if (r.pathPrefix.length > 0) route.pathPrefix = r.pathPrefix;
        if (r.targetPath.length > 0) route.targetPath = r.targetPath;
        route.authRequired = r.authRequired;
        route.cacheEnabled = r.cacheEnabled;
        route.updatedAt = currentTimestamp();
        route.modifiedBy = r.modifiedBy;

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
        repo.remove(id);
    }

    size_t countByApp(HtmlAppId appId) {
        return repo.countByApp(appId);
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
