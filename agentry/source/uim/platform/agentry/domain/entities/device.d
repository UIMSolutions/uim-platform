/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.entities.device;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

struct Device {
    mixin TenantEntity!(DeviceId);

    MobileApplicationId mobileApplicationId;
    string deviceName;
    string deviceModel;
    string manufacturer;
    AppPlatform platform = AppPlatform.android;
    string osVersion;
    string appVersionInstalled;
    DeviceStatus status = DeviceStatus.enrolled;
    long enrolledAt;
    long lastSeenAt;
    string pushToken;
    string userId;
    string userEmail;
    string groupName;
    bool isManaged;
    string mdmDeviceId;

    Json toJson() const {
        auto j = entityToJson
            .set("mobileApplicationId", mobileApplicationId.value)
            .set("deviceName", deviceName)
            .set("deviceModel", deviceModel)
            .set("manufacturer", manufacturer)
            .set("platform", platform.to!string)
            .set("osVersion", osVersion)
            .set("appVersionInstalled", appVersionInstalled)
            .set("status", status.to!string)
            .set("enrolledAt", enrolledAt)
            .set("lastSeenAt", lastSeenAt)
            .set("userId", userId)
            .set("userEmail", userEmail)
            .set("groupName", groupName)
            .set("isManaged", isManaged)
            .set("mdmDeviceId", mdmDeviceId);
        return j;
    }
}
