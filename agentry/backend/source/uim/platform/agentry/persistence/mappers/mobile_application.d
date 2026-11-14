/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.persistence.mappers.mobile_application;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// MobileApplication ⇄ snapshot record.
struct MobileApplicationMapper {
  static Json toRecord(const MobileApplication e) {
    auto r = baseRecord(e);
    r["name"] = e.name;
    r["description"] = e.description;
    r["platform"] = enumValue(e.platform);
    r["status"] = enumValue(e.status);
    r["iconUrl"] = e.iconUrl;
    r["category"] = e.category;
    r["vendor"] = e.vendor;
    r["contactEmail"] = e.contactEmail;
    r["backendSystemId"] = e.backendSystemId;
    r["offlineCapable"] = e.offlineCapable;
    r["pushNotificationsEnabled"] = e.pushNotificationsEnabled;
    r["minOsVersion"] = e.minOsVersion;
    r["packageName"] = e.packageName;
    return r;
  }

  static MobileApplication fromRecord(Json r) {
    MobileApplication e;
    readBase(e, r);
    e.name = fieldString(r, "name");
    e.description = fieldString(r, "description");
    e.platform = fieldEnum!AppPlatform(r, "platform", AppPlatform.android);
    e.status = fieldEnum!AppStatus(r, "status", AppStatus.draft);
    e.iconUrl = fieldString(r, "iconUrl");
    e.category = fieldString(r, "category");
    e.vendor = fieldString(r, "vendor");
    e.contactEmail = fieldString(r, "contactEmail");
    e.backendSystemId = fieldString(r, "backendSystemId");
    e.offlineCapable = fieldBool(r, "offlineCapable");
    e.pushNotificationsEnabled = fieldBool(r, "pushNotificationsEnabled");
    e.minOsVersion = fieldString(r, "minOsVersion");
    e.packageName = fieldString(r, "packageName");
    return e;
  }
}
