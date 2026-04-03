module uim.platform.mobile.domain.ports.offline_config_repository;

import uim.platform.mobile.domain.entities.offline_config;
import uim.platform.mobile.domain.types;

/// Port: outgoing — offline configuration persistence.
interface OfflineConfigRepository
{
    OfflineConfig findById(OfflineConfigId id);
    OfflineConfig[] findByApp(MobileAppId appId);
    void save(OfflineConfig config);
    void update(OfflineConfig config);
    void remove(OfflineConfigId id);
}
