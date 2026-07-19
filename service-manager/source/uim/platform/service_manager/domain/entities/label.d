module uim.platform.service_manager.domain.entities.label;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/**
    * Represents a label associated with a resource in the service manager.
    * Each label consists of a key-value pair and is linked to a specific resource.
    * The resource can be of various types, such as services, instances, or other entities managed by the service manager.
    * The Label struct includes a method to convert its data into a JSON format, which can be useful for API responses or storage.
    *
    * @property resourceId The unique identifier of the resource to which the label is attached.
    * @property resourceType The type of the resource (e.g., "service", "instance").
    * @property key The key of the label, representing the name or category of the label.
    * @property value The value of the label, representing the specific information or attribute associated with the key.
    */
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
