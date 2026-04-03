module application.usecases.manage_mobile_apps;

import uim.platform.xyz.application.dto;
import domain.entities.mobile_app;
import domain.ports.mobile_app_repository;
import domain.types;

/// Use case: manage mobile app definitions.
class ManageMobileAppsUseCase
{
    private MobileAppRepository repo;

    this(MobileAppRepository repo)
    {
        this.repo = repo;
    }

    CommandResult create(CreateMobileAppRequest req)
    {
        if (req.name.length == 0)
            return CommandResult(false, "", "App name is required");

        if (req.bundleId.length == 0)
            return CommandResult(false, "", "Bundle ID is required");

        // Check bundle ID uniqueness
        auto existing = repo.findByBundleId(req.tenantId, req.bundleId);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Bundle ID already registered");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        MobileApp app;
        app.id = id;
        app.tenantId = req.tenantId;
        app.name = req.name;
        app.displayName = req.displayName.length > 0 ? req.displayName : req.name;
        app.description = req.description;
        app.bundleId = req.bundleId;
        app.platforms = parsePlatforms(req.platforms);
        app.authType = parseAuthType(req.authType);
        app.status = AppStatus.draft;
        app.iconUrl = req.iconUrl;
        app.deepLinkScheme = req.deepLinkScheme;
        app.pushEnabled = req.pushEnabled;
        app.offlineEnabled = req.offlineEnabled;
        app.analyticsEnabled = req.analyticsEnabled;
        app.loggingEnabled = req.loggingEnabled;
        app.securityPolicyId = req.securityPolicyId;
        app.backendUrl = req.backendUrl;
        app.customSettings = req.customSettings;
        app.createdBy = req.createdBy;
        app.createdAt = clockSeconds();
        app.updatedAt = app.createdAt;

        repo.save(app);
        return CommandResult(true, id, "");
    }

    CommandResult update(MobileAppId id, UpdateMobileAppRequest req)
    {
        auto app = repo.findById(id);
        if (app.id.length == 0)
            return CommandResult(false, "", "Mobile app not found");

        if (req.displayName.length > 0) app.displayName = req.displayName;
        if (req.description.length > 0) app.description = req.description;
        if (req.iconUrl.length > 0) app.iconUrl = req.iconUrl;
        if (req.deepLinkScheme.length > 0) app.deepLinkScheme = req.deepLinkScheme;
        app.pushEnabled = req.pushEnabled;
        app.offlineEnabled = req.offlineEnabled;
        app.analyticsEnabled = req.analyticsEnabled;
        app.loggingEnabled = req.loggingEnabled;
        if (req.securityPolicyId.length > 0) app.securityPolicyId = req.securityPolicyId;
        if (req.backendUrl.length > 0) app.backendUrl = req.backendUrl;
        if (req.customSettings.length > 0) app.customSettings = req.customSettings;
        if (req.status.length > 0) app.status = parseAppStatus(req.status);
        app.updatedAt = clockSeconds();

        repo.update(app);
        return CommandResult(true, id, "");
    }

    CommandResult activate(MobileAppId id)
    {
        auto app = repo.findById(id);
        if (app.id.length == 0)
            return CommandResult(false, "", "Mobile app not found");
        app.status = AppStatus.active;
        app.updatedAt = clockSeconds();
        repo.update(app);
        return CommandResult(true, id, "");
    }

    CommandResult suspend(MobileAppId id)
    {
        auto app = repo.findById(id);
        if (app.id.length == 0)
            return CommandResult(false, "", "Mobile app not found");
        app.status = AppStatus.suspended;
        app.updatedAt = clockSeconds();
        repo.update(app);
        return CommandResult(true, id, "");
    }

    MobileApp getById(MobileAppId id)
    {
        return repo.findById(id);
    }

    MobileApp[] listByTenant(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    CommandResult remove(MobileAppId id)
    {
        auto app = repo.findById(id);
        if (app.id.length == 0)
            return CommandResult(false, "", "Mobile app not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}

private MobilePlatform[] parsePlatforms(string[] platforms)
{
    MobilePlatform[] result;
    foreach (p; platforms)
    {
        switch (p)
        {
        case "ios": result ~= MobilePlatform.ios; break;
        case "android": result ~= MobilePlatform.android; break;
        case "windows": result ~= MobilePlatform.windows; break;
        case "webApp": result ~= MobilePlatform.webApp; break;
        default: break;
        }
    }
    return result;
}

private MobileAuthType parseAuthType(string s)
{
    switch (s)
    {
    case "saml": return MobileAuthType.saml;
    case "basicAuth": return MobileAuthType.basicAuth;
    case "certificateBased": return MobileAuthType.certificateBased;
    case "biometric": return MobileAuthType.biometric;
    case "apiKey": return MobileAuthType.apiKey;
    case "noAuth": return MobileAuthType.noAuth;
    default: return MobileAuthType.oauth2;
    }
}

private AppStatus parseAppStatus(string s)
{
    switch (s)
    {
    case "active": return AppStatus.active;
    case "suspended": return AppStatus.suspended;
    case "deprecated_": return AppStatus.deprecated_;
    case "retired": return AppStatus.retired;
    default: return AppStatus.draft;
    }
}

private long clockSeconds()
{
    import core.time : MonoTime;
    return MonoTime.currTime.ticks / 1_000_000_000;
}
