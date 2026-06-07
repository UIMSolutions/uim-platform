/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.entities.mobile_application;

import uim.platform.agentry;

// mixin(ShowModule!());

@safe:

struct MobileApplication {
    mixin TenantEntity!(MobileApplicationId);

    string name;
    string description;
    AppPlatform platform = AppPlatform.android;
    AppStatus status = AppStatus.draft;
    string iconUrl;
    string category;
    string vendor;
    string contactEmail;
    string backendSystemId;
    bool offlineCapable;
    bool pushNotificationsEnabled;
    string minOsVersion;
    string packageName;

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("platform", platform.to!string)
            .set("status", status.to!string)
            .set("iconUrl", iconUrl)
            .set("category", category)
            .set("vendor", vendor)
            .set("contactEmail", contactEmail)
            .set("backendSystemId", backendSystemId)
            .set("offlineCapable", offlineCapable)
            .set("pushNotificationsEnabled", pushNotificationsEnabled)
            .set("minOsVersion", minOsVersion)
            .set("packageName", packageName);
        return j;
    }
}
