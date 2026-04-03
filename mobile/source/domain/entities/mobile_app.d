module uim.platform.mobile.domain.entities.mobile_app;

import uim.platform.mobile.domain.types;

/// A mobile application definition with platform-specific configurations.
struct MobileApp
{
    MobileAppId id;
    TenantId tenantId;
    string name;
    string displayName;
    string description;
    string bundleId;                // iOS bundle ID or Android package name
    MobilePlatform[] platforms;
    MobileAuthType authType = MobileAuthType.oauth2;
    AppStatus status = AppStatus.draft;
    string iconUrl;
    string deepLinkScheme;
    bool pushEnabled = false;
    bool offlineEnabled = false;
    bool analyticsEnabled = true;
    bool loggingEnabled = true;
    SecurityPolicyId securityPolicyId;
    string backendUrl;              // OData/REST backend endpoint
    string[string] customSettings;  // app-specific key/value config
    string createdBy;
    long createdAt;
    long updatedAt;
}
