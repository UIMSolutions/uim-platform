module uim.platform.xyz.domain.ports.app_version_repository;

import domain.entities.app_version;
import domain.types;

/// Port: outgoing — app version persistence.
interface AppVersionRepository
{
    AppVersion findById(AppVersionId id);
    AppVersion[] findByApp(MobileAppId appId);
    AppVersion[] findByAppAndPlatform(MobileAppId appId, MobilePlatform platform);
    AppVersion findLatestReleased(MobileAppId appId, MobilePlatform platform);
    void save(AppVersion version_);
    void update(AppVersion version_);
    void remove(AppVersionId id);
}
