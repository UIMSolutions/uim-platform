/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.persistence.mappers.device;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// MobileDevice ⇄ snapshot record.
struct DeviceMapper {
  static Json toRecord(const MobileDevice e) {
    auto r = baseRecord(e);
    r["mobileApplicationId"] = e.mobileApplicationId.value;
    r["deviceName"] = e.deviceName;
    r["deviceModel"] = e.deviceModel;
    r["manufacturer"] = e.manufacturer;
    r["platform"] = enumValue(e.platform);
    r["osVersion"] = e.osVersion;
    r["appVersionInstalled"] = e.appVersionInstalled;
    r["status"] = enumValue(e.status);
    r["enrolledAt"] = e.enrolledAt;
    r["lastSeenAt"] = e.lastSeenAt;
    r["pushToken"] = e.pushToken;
    r["userId"] = e.userId.value;
    r["userEmail"] = e.userEmail;
    r["groupName"] = e.groupName;
    r["isManaged"] = e.isManaged;
    r["mdmDeviceId"] = e.mdmDeviceId;
    return r;
  }

  static MobileDevice fromRecord(Json r) {
    MobileDevice e;
    readBase(e, r);
    e.mobileApplicationId = MobileApplicationId(fieldString(r, "mobileApplicationId"));
    e.deviceName = fieldString(r, "deviceName");
    e.deviceModel = fieldString(r, "deviceModel");
    e.manufacturer = fieldString(r, "manufacturer");
    e.platform = fieldEnum!AppPlatform(r, "platform", AppPlatform.android);
    e.osVersion = fieldString(r, "osVersion");
    e.appVersionInstalled = fieldString(r, "appVersionInstalled");
    e.status = fieldEnum!DeviceStatus(r, "status", DeviceStatus.enrolled);
    e.enrolledAt = fieldLong(r, "enrolledAt");
    e.lastSeenAt = fieldLong(r, "lastSeenAt");
    e.pushToken = fieldString(r, "pushToken");
    e.userId = UserId(fieldString(r, "userId"));
    e.userEmail = fieldString(r, "userEmail");
    e.groupName = fieldString(r, "groupName");
    e.isManaged = fieldBool(r, "isManaged");
    e.mdmDeviceId = fieldString(r, "mdmDeviceId");
    return e;
  }
}
///
unittest {
  mixin(ShowTest!("DeviceMapper"));

  auto d = MobileDevice(TenantId("t1"), DeviceId("d1"), UserId("u1"));
  d.deviceName = "Tech-01";
  d.platform = AppPlatform.ios;
  d.status = DeviceStatus.suspended;
  d.lastSeenAt = 4711;
  d.isManaged = true;
  auto back = DeviceMapper.fromRecord(DeviceMapper.toRecord(d));
  assert(back.id == d.id && back.tenantId == d.tenantId && back.createdBy == d.createdBy);
  assert(back.deviceName == "Tech-01" && back.platform == AppPlatform.ios);
  assert(back.status == DeviceStatus.suspended && back.lastSeenAt == 4711 && back.isManaged);

  auto v = AppVersion(TenantId("t1"));
  v.status = AppVersionStatus.deprecated_;
  assert(AppVersionMapper.toRecord(v)["status"].get!string == "deprecated");
  assert(AppVersionMapper.fromRecord(AppVersionMapper.toRecord(v)).status == AppVersionStatus.deprecated_);
}
