/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.persistence.mappers.directory;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Converts between AccountDirectory and its snapshot record.
struct AccountDirectoryMapper {
  static Json toRecord(const AccountDirectory e) {
    auto r = baseRecord(e);
    r["globalAccountId"] = e.globalAccountId.value;
    r["parentDirectoryId"] = e.parentDirectoryId.value;
    r["displayName"] = e.displayName;
    r["description"] = e.description;
    r["status"] = enumName(e.status);
    auto features = Json.emptyArray;
    foreach (f; e.features)
      features ~= Json(enumName(f));
    r["features"] = features;
    r["manageEntitlements"] = e.manageEntitlements;
    r["manageAuthorizations"] = e.manageAuthorizations;
    r["labels"] = propertiesToJson(e.labels);
    r["customProperties"] = propertiesToJson(e.customProperties);
    return r;
  }

  static AccountDirectory fromRecord(Json r) {
    AccountDirectory e;
    readBase(e, r);
    e.globalAccountId = GlobalAccountId(fieldString(r, "globalAccountId"));
    e.parentDirectoryId = DirectoryId(fieldString(r, "parentDirectoryId"));
    e.displayName = fieldString(r, "displayName");
    e.description = fieldString(r, "description");
    e.status = fieldEnum!DirectoryStatus(r, "status", DirectoryStatus.active);
    foreach (f; fieldStrings(r, "features")) {
      DirectoryFeature feature;
      if (tryParseEnum!DirectoryFeature(f, feature))
        e.features ~= feature;
    }
    e.manageEntitlements = fieldBool(r, "manageEntitlements");
    e.manageAuthorizations = fieldBool(r, "manageAuthorizations");
    e.labels = fieldMap(r, "labels");
    e.customProperties = fieldMap(r, "customProperties");
    return e;
  }
}
