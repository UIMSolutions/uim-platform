module uim.platform.data_retention.domain.entities.application_group;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct ApplicationGroup {
    ApplicationGroupId id;
    TenantId tenantId;
    string name;
    string description;
    ApplicationGroupScope scope_ = ApplicationGroupScope.global;
    string[] applicationIds;
    bool isActive = true;
    UserId createdBy;
    long createdAt;
    long updatedAt;
}
