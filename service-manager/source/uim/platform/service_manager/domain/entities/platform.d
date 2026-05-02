module uim.platform.service_manager.domain.entities.platform;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct Platform {
    mixin TenantEntity!(PlatformId);

    string name;
    string description;
    PlatformType type = PlatformType.other;
    PlatformStatus status = PlatformStatus.active;
    string brokerUrl;
    string credentials;
    string region;
    string subaccountId;
    
    Json toJson() const {
        return entityToJson()
            .set("name", name)
            .set("description", description)
            .set("type", type.toString())
            .set("status", status.toString())
            .set("brokerUrl", brokerUrl)
            .set("credentials", credentials)
            .set("region", region)
            .set("subaccountId", subaccountId);
    }
}
