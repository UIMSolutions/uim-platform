/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.types;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
// ID aliases
struct MobileAppId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct DeviceRegistrationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct PushNotificationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct PushRegistrationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct AppConfigurationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct FeatureRestrictionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct ClientResourceId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct AppVersionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct UsageReportId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct OfflineStoreId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct UserSessionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct ClientLogEntryId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
