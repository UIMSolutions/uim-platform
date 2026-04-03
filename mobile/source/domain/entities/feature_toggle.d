module uim.platform.xyz.domain.entities.feature_toggle;

import domain.types;

/// A remote feature toggle / feature flag for mobile apps.
struct FeatureToggle
{
    FeatureToggleId id;
    MobileAppId appId;
    TenantId tenantId;
    string key;                     // unique feature key e.g. "dark_mode"
    string name;
    string description;
    ToggleStatus status = ToggleStatus.disabled;
    int rolloutPercentage = 0;      // 0-100 for percentage rollout
    string[] enabledUserIds;        // explicit user overrides
    string[] enabledSegments;       // segment-based targeting
    MobilePlatform[] platforms;     // empty = all platforms
    string minimumAppVersion;       // version gate
    string defaultValue;            // value when disabled
    string enabledValue;            // value when enabled
    string variantJson;             // JSON for A/B test variants
    long scheduledEnableAt;
    long scheduledDisableAt;
    string createdBy;
    long createdAt;
    long updatedAt;
}
