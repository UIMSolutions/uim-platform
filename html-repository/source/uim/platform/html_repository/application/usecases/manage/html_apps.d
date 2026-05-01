/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.manage.html_apps;

import uim.platform.html_repository.domain.ports.repositories.html_apps;
import uim.platform.html_repository.domain.entities.html_app;
import uim.platform.html_repository.domain.services.deployment_validator;
import uim.platform.html_repository.domain.types;
import uim.platform.html_repository.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageHtmlAppsUseCase { // TODO: UIMUseCase {
    private HtmlAppRepository repo;

    this(HtmlAppRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateHtmlAppRequest r) {
        if (!DeploymentValidator.validateAppName(r.name))
            return CommandResult(false, "", "Invalid application name");

        auto existing = repo.findByName(r.tenantId, r.name);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Application with this name already exists");

        HtmlApp app;
        app.id = randomUUID();
        app.tenantId = r.tenantId;
        app.spaceId = r.spaceId;
        app.serviceInstanceId = r.serviceInstanceId;
        app.name = r.name;
        app.namespace_ = r.namespace_;
        app.description = r.description;
        app.visibility = parseVisibility(r.visibility);
        app.status = AppStatus.active;
        app.totalSizeBytes = 0;
        app.createdAt = currentTimestamp();
        app.updatedAt = app.createdAt;
        app.createdBy = r.createdBy;
        app.modifiedBy = r.createdBy;

        repo.save(app);
        return CommandResult(true, app.id, "");
    }

    CommandResult update(HtmlAppId id, UpdateHtmlAppRequest r) {
        auto app = repo.findById(id);
        if (app.isNull)
            return CommandResult(false, "", "App not found");

        if (r.description.length > 0) app.description = r.description;
        if (r.visibility.length > 0) app.visibility = parseVisibility(r.visibility);
        app.updatedAt = currentTimestamp();
        app.modifiedBy = r.modifiedBy;

        repo.update(app);
        return CommandResult(true, app.id, "");
    }

    HtmlApp getById(HtmlAppId id) {
        return repo.findById(id);
    }

    HtmlApp[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    HtmlApp[] listPublic(TenantId tenantId) {
        return repo.findPublic(tenantId);
    }

    void remove(HtmlAppId id) {
        repo.remove(id);
    }

    size_t countByTenant(TenantId tenantId) {
        return repo.countByTenant(tenantId);
    }

    private static AppVisibility parseVisibility(string v) {
        switch (v) {
            case "public": return AppVisibility.public_;
            case "private": return AppVisibility.private_;
            case "restricted": return AppVisibility.restricted;
            default: return AppVisibility.private_;
        }
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
