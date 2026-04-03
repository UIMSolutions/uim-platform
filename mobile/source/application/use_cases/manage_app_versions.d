module uim.platform.mobile.application.usecases.manage_app_versions;

import uim.platform.mobile.application.dto;
import uim.platform.mobile.domain.entities.app_version;
import uim.platform.mobile.domain.ports.app_version_repository;
import uim.platform.mobile.domain.services.version_checker;
import uim.platform.mobile.domain.types;

/// Use case: manage app versions and OTA updates.
class ManageAppVersionsUseCase
{
    private AppVersionRepository repo;
    private VersionChecker versionChecker;

    this(AppVersionRepository repo, VersionChecker versionChecker)
    {
        this.repo = repo;
        this.versionChecker = versionChecker;
    }

    CommandResult create(CreateAppVersionRequest req)
    {
        if (req.versionNumber.length == 0)
            return CommandResult(false, "", "Version number is required");

        if (req.appId.length == 0)
            return CommandResult(false, "", "App ID is required");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        AppVersion v;
        v.id = id;
        v.appId = req.appId;
        v.tenantId = req.tenantId;
        v.versionNumber = req.versionNumber;
        v.buildNumber = req.buildNumber;
        v.platform = parsePlatform(req.platform);
        v.status = VersionStatus.development;
        v.updatePolicy = parseUpdatePolicy(req.updatePolicy);
        v.releaseNotes = req.releaseNotes;
        v.downloadUrl = req.downloadUrl;
        v.binarySize = req.binarySize;
        v.checksum = req.checksum;
        v.minimumOsVersion = req.minimumOsVersion;
        v.requiredPermissions = req.requiredPermissions;
        v.forceUpdate = req.forceUpdate;
        v.releasedBy = req.releasedBy;
        v.createdAt = clockSeconds();

        repo.save(v);
        return CommandResult(true, id, "");
    }

    CommandResult release(AppVersionId id)
    {
        auto v = repo.findById(id);
        if (v.id.length == 0)
            return CommandResult(false, "", "App version not found");
        v.status = VersionStatus.released;
        v.releasedAt = clockSeconds();
        repo.update(v);
        return CommandResult(true, id, "");
    }

    CommandResult revoke(AppVersionId id)
    {
        auto v = repo.findById(id);
        if (v.id.length == 0)
            return CommandResult(false, "", "App version not found");
        v.status = VersionStatus.revoked;
        repo.update(v);
        return CommandResult(true, id, "");
    }

    VersionCheckResponse checkForUpdate(MobileAppId appId, string platform, string clientVersion)
    {
        auto latest = repo.findLatestReleased(appId, parsePlatform(platform));
        auto result = versionChecker.checkForUpdate(clientVersion, latest);

        VersionCheckResponse resp;
        resp.updateAvailable = result.updateAvailable;
        resp.latestVersion = result.latestVersion;
        resp.downloadUrl = result.downloadUrl;
        resp.releaseNotes = result.releaseNotes;
        resp.forceUpdate = result.forceUpdate;
        return resp;
    }

    AppVersion getById(AppVersionId id) { return repo.findById(id); }
    AppVersion[] listByApp(MobileAppId appId) { return repo.findByApp(appId); }

    CommandResult remove(AppVersionId id)
    {
        auto v = repo.findById(id);
        if (v.id.length == 0)
            return CommandResult(false, "", "App version not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}

private MobilePlatform parsePlatform(string s)
{
    switch (s)
    {
    case "ios": return MobilePlatform.ios;
    case "android": return MobilePlatform.android;
    case "windows": return MobilePlatform.windows;
    case "webApp": return MobilePlatform.webApp;
    default: return MobilePlatform.ios;
    }
}

private UpdatePolicy parseUpdatePolicy(string s)
{
    switch (s)
    {
    case "recommended": return UpdatePolicy.recommended;
    case "forced": return UpdatePolicy.forced;
    case "blockedBelow": return UpdatePolicy.blockedBelow;
    default: return UpdatePolicy.optional;
    }
}

private long clockSeconds()
{
    import core.time : MonoTime;
    return MonoTime.currTime.ticks / 1_000_000_000;
}
