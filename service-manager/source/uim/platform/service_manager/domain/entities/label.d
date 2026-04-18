module uim.platform.service_manager.domain.entities.label;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct Label {
    LabelId id;
    TenantId tenantId;
    string resourceId;
    string resourceType;
    string key;
    string value;
    long createdAt;
}
