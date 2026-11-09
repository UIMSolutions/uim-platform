/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.persistence.mappers.retention_policy;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

struct RetentionPolicyMapper {
  static Json toRecord(const RetentionPolicy e) {
    auto r = baseRecord(e);
    r["name"] = e.name;
    r["description"] = e.description;
    r["retentionDays"] = e.retentionDays;
    r["categories"] = categoriesToJson(e.categories);
    r["status"] = e.status.to!string;
    r["isDefault"] = e.isDefault;
    return r;
  }

  static RetentionPolicy fromRecord(Json r) {
    RetentionPolicy e;
    readBase(e, r);
    e.name = fieldString(r, "name");
    e.description = fieldString(r, "description");
    e.retentionDays = fieldInt(r, "retentionDays", 90);
    e.categories = categoriesFromJson(r, "categories");
    e.status = fieldEnum!RetentionStatus(r, "status", RetentionStatus.active);
    e.isDefault = fieldBool(r, "isDefault");
    return e;
  }
}
