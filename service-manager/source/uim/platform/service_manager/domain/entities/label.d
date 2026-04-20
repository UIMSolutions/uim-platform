module uim.platform.service_manager.domain.entities.label;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct Label {
    mixin TenantEntity!(LabelId);

    string resourceId;
    string resourceType;
    string key;
    string value;

    Json toJson() const {
        return Json.emptyObject
            .set("resourceId", resourceId)
            .set("resourceType", resourceType)
            .set("key", key)
            .set("value", value);
    }
}
