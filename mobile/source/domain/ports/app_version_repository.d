module uim.platform.mobile.domain.ports.app_version_repository;

import uim.platform.mobile.domain.entities.app_version;
import uim.platform.mobile.domain.types;

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
