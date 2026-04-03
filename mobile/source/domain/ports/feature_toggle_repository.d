module uim.platform.xyz.domain.ports.feature_toggle_repository;

import domain.entities.feature_toggle;
import domain.types;

/// Port: outgoing — feature toggle persistence.
interface FeatureToggleRepository
{
    FeatureToggle findById(FeatureToggleId id);
    FeatureToggle findByKey(MobileAppId appId, string key);
    FeatureToggle[] findByApp(MobileAppId appId);
    FeatureToggle[] findByStatus(MobileAppId appId, ToggleStatus status);
    void save(FeatureToggle toggle);
    void update(FeatureToggle toggle);
    void remove(FeatureToggleId id);
}
