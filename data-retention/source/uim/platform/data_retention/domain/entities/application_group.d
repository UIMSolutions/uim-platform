module uim.platform.data_retention.domain.entities.application_group;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct ApplicationGroup {
    mixin TenantEntity!(ApplicationGroupId);

    string name;
    string description;
    ApplicationGroupScope scope_ = ApplicationGroupScope.global;
    string[] applicationIds;
    bool isActive = true;
    
    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("scope", scope_)
            .set("applicationIds", applicationIds)
            .set("isActive", isActive);
    }
}
