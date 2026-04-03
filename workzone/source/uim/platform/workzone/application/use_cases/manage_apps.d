module application.usecases.manage_apps;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.app_registration;
import domain.ports.app_repository;
import uim.platform.xyz.application.dto;

class ManageAppsUseCase
{
    private AppRepository repo;

    this(AppRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createApp(CreateAppRequest req)
    {
        if (req.name.length == 0)
            return CommandResult("", "App name is required");

        auto now = Clock.currStdTime();
        auto app = AppRegistration();
        app.id = randomUUID().toString();
        app.tenantId = req.tenantId;
        app.name = req.name;
        app.description = req.description;
        app.launchUrl = req.launchUrl;
        app.icon = req.icon;
        app.vendor = req.vendor;
        app.version_ = req.version_;
        app.status = AppStatus.active;
        app.supportedPlatforms = req.supportedPlatforms;
        app.tags = req.tags;
        app.appConfig = req.appConfig;
        app.createdAt = now;
        app.updatedAt = now;

        repo.save(app);
        return CommandResult(app.id, "");
    }

    AppRegistration* getApp(AppId id, TenantId tenantId)
    {
        return repo.findById(id, tenantId);
    }

    AppRegistration[] listApps(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    AppRegistration[] listByStatus(AppStatus status, TenantId tenantId)
    {
        return repo.findByStatus(status, tenantId);
    }

    CommandResult updateApp(UpdateAppRequest req)
    {
        auto app = repo.findById(req.id, req.tenantId);
        if (app is null)
            return CommandResult("", "App not found");

        if (req.name.length > 0) app.name = req.name;
        if (req.description.length > 0) app.description = req.description;
        if (req.launchUrl.length > 0) app.launchUrl = req.launchUrl;
        if (req.icon.length > 0) app.icon = req.icon;
        app.status = req.status;
        app.appConfig = req.appConfig;
        app.updatedAt = Clock.currStdTime();

        repo.update(*app);
        return CommandResult(app.id, "");
    }

    void deleteApp(AppId id, TenantId tenantId)
    {
        repo.remove(id, tenantId);
    }
}
