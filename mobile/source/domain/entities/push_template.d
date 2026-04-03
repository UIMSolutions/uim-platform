module uim.platform.mobile.domain.entities.push_template;

import uim.platform.mobile.domain.types;

/// A reusable push notification template.
struct PushTemplate
{
    PushTemplateId id;
    MobileAppId appId;
    TenantId tenantId;
    string name;
    string titleTemplate;           // supports {{variable}} placeholders
    string bodyTemplate;
    string imageUrl;
    string deepLink;
    PushPriority defaultPriority = PushPriority.normal;
    string[string] defaultData;
    string sound = "default";
    bool silent = false;
    string locale;                  // default locale
    string createdBy;
    long createdAt;
    long updatedAt;
}
