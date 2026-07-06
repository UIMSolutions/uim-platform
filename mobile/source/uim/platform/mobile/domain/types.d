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
    mixin(IdTemplate);
}
struct DeviceRegistrationId  {
    mixin(IdTemplate);
}
struct PushNotificationId  {
    mixin(IdTemplate);
}
struct PushRegistrationId  {
    mixin(IdTemplate);
}
struct AppConfigurationId  {
    mixin(IdTemplate);
}
struct FeatureRestrictionId  {
    mixin(IdTemplate);
}
struct ClientResourceId  {
    mixin(IdTemplate);
}
struct AppVersionId  {
    mixin(IdTemplate);
}
struct UsageReportId  {
    mixin(IdTemplate);
}
struct OfflineStoreId  {
    mixin(IdTemplate);
}
struct UserSessionId  {
    mixin(IdTemplate);
}
struct ClientLogEntryId  {
    mixin(IdTemplate);
}
