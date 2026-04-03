module uim.platform.workzone.domain.entities.app_registration;

import uim.platform.workzone.domain.types;

/// A registered business application — SAP or third-party app entry.
struct AppRegistration
{
    AppId id;
    TenantId tenantId;
    string name;
    string description;
    string launchUrl;
    string icon;
    string vendor;
    string version_;
    AppStatus status = AppStatus.active;
    string[] supportedPlatforms;  // "web", "mobile", "desktop"
    string[] tags;
    RoleId[] allowedRoleIds;
    AppConfig appConfig;
    long createdAt;
    long updatedAt;
}

/// App-specific configuration.
struct AppConfig
{
    string authType;         // "saml", "oauth2", "basic", "none"
    string authEndpoint;
    bool enableSso;
    string sapSystemAlias;
    string oDataServiceUrl;
    string componentId;
}
