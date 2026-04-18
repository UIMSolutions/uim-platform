module uim.platform.service_manager.domain.entities.platform;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct Platform {
    PlatformId id;
    TenantId tenantId;
    string name;
    string description;
    PlatformType type = PlatformType.other;
    PlatformStatus status = PlatformStatus.active;
    string brokerUrl;
    string credentials;
    string region;
    string subaccountId;
    string createdBy;
    long createdAt;
    long updatedAt;
}
