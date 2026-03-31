module domain.ports.offline_config_repository;

import domain.entities.offline_config;
import domain.types;

/// Port: outgoing — offline configuration persistence.
interface OfflineConfigRepository
{
    OfflineConfig findById(OfflineConfigId id);
    OfflineConfig[] findByApp(MobileAppId appId);
    void save(OfflineConfig config);
    void update(OfflineConfig config);
    void remove(OfflineConfigId id);
}
