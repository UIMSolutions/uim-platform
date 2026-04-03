module uim.platform.mobile.infrastructure.persistence.memory.app_version_repo;

import uim.platform.mobile.domain.types;
import uim.platform.mobile.domain.entities.app_version;
import uim.platform.mobile.domain.ports.app_version_repository;

import std.algorithm : filter, sort;
import std.array : array;

class MemoryAppVersionRepository : AppVersionRepository
{
    private AppVersion[AppVersionId] store;

    AppVersion findById(AppVersionId id)
    {
        if (auto p = id in store)
            return *p;
        return AppVersion.init;
    }

    AppVersion[] findByApp(MobileAppId appId)
    {
        return store.byValue().filter!(e => e.appId == appId).array;
    }

    AppVersion[] findByAppAndPlatform(MobileAppId appId, MobilePlatform platform)
    {
        return store.byValue()
            .filter!(e => e.appId == appId && e.platform == platform)
            .array;
    }

    AppVersion findLatestReleased(MobileAppId appId, MobilePlatform platform)
    {
        auto released = store.byValue()
            .filter!(e => e.appId == appId && e.platform == platform
                && e.status == VersionStatus.released)
            .array;
        if (released.length == 0)
            return AppVersion.init;
        released.sort!((a, b) => a.releasedAt > b.releasedAt);
        return released[0];
    }

    void save(AppVersion version_) { store[version_.id] = version_; }
    void update(AppVersion version_) { store[version_.id] = version_; }
    void remove(AppVersionId id) { store.remove(id); }
}
