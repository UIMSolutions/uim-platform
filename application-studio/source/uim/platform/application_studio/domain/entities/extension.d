/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.extension;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

struct Extension {
    ExtensionId id;
    TenantId tenantId;
    string name;
    string description;
    ExtensionScope scope_ = ExtensionScope.predefined;
    ExtensionStatus status = ExtensionStatus.active;
    string version_;
    string publisher;
    string category;
    string dependencies;
    string capabilities;
    string iconUrl;
    string createdAt;
    string modifiedAt;
    string createdBy;
    string modifiedBy;

    Json extensionToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("name", name)
            .set("description", description)
            .set("scope", scope_.to!string)
            .set("status", status.to!string)
            .set("version", version_)
            .set("publisher", publisher)
            .set("category", category)
            .set("dependencies", dependencies)
            .set("capabilities", capabilities)
            .set("iconUrl", iconUrl)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy);
    }
}
