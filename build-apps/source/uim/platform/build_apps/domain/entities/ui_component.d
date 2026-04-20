/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.entities.ui_component;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

struct UIComponent {
    mixin TenantEntity!(UIComponentId);

    string name;
    string description;
    ComponentCategory category = ComponentCategory.basic;
    ComponentStatus status = ComponentStatus.active;
    string version_;
    string properties;
    string styleProperties;
    string eventBindings;
    string dataBindings;
    string childComponents;
    string iconUrl;
    string previewUrl;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("category", category.to!string)
            .set("status", status.to!string)
            .set("version", version_)
            .set("properties", properties)
            .set("styleProperties", styleProperties)
            .set("eventBindings", eventBindings)
            .set("dataBindings", dataBindings)
            .set("childComponents", childComponents)
            .set("iconUrl", iconUrl)
            .set("previewUrl", previewUrl);
    }
}
