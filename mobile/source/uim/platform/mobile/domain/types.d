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

    mixin DomainId;
}
struct DeviceRegistrationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct PushNotificationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct PushRegistrationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct AppConfigurationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct FeatureRestrictionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ClientResourceId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct AppVersionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct UsageReportId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct OfflineStoreId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct UserSessionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ClientLogEntryId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
