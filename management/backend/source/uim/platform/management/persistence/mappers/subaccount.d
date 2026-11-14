/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.persistence.mappers.subaccount;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Converts between Subaccount and its snapshot record.
struct SubaccountMapper {
  static Json toRecord(const Subaccount e) {
    auto r = baseRecord(e);
    r["globalAccountId"] = e.globalAccountId.value;
    r["parentDirectoryId"] = e.parentDirectoryId.value;
    r["displayName"] = e.displayName;
    r["description"] = e.description;
    r["subdomain"] = e.subdomain;
    r["region"] = e.region;
    r["status"] = enumName(e.status);
    r["usage"] = enumName(e.usage);
    r["betaEnabled"] = e.betaEnabled;
    r["usedForProduction"] = e.usedForProduction;
    r["technicalName"] = e.technicalName;
    r["labels"] = propertiesToJson(e.labels);
    r["customProperties"] = propertiesToJson(e.customProperties);
    return r;
  }

  static Subaccount fromRecord(Json r) {
    Subaccount e;
    readBase(e, r);
    e.globalAccountId = GlobalAccountId(fieldString(r, "globalAccountId"));
    e.parentDirectoryId = DirectoryId(fieldString(r, "parentDirectoryId"));
    e.displayName = fieldString(r, "displayName");
    e.description = fieldString(r, "description");
    e.subdomain = fieldString(r, "subdomain");
    e.region = fieldString(r, "region");
    e.status = fieldEnum!SubaccountStatus(r, "status", SubaccountStatus.active);
    e.usage = fieldEnum!SubaccountUsage(r, "usage", SubaccountUsage.unset);
    e.betaEnabled = fieldBool(r, "betaEnabled");
    e.usedForProduction = fieldBool(r, "usedForProduction");
    e.technicalName = fieldString(r, "technicalName");
    e.labels = fieldMap(r, "labels");
    e.customProperties = fieldMap(r, "customProperties");
    return e;
  }
}

///
unittest {
  mixin(ShowTest!("SubaccountMapper"));

  auto s = Subaccount(TenantId("t1"));
  s.displayName = "Dev";
  s.status = SubaccountStatus.suspended;
  s.usage = SubaccountUsage.development;
  s.labels = ["cost": "CC1"];
  auto back = SubaccountMapper.fromRecord(SubaccountMapper.toRecord(s));
  assert(back.id == s.id && back.tenantId == s.tenantId && back.createdAt == s.createdAt);
  assert(back.displayName == "Dev" && back.status == SubaccountStatus.suspended);
  assert(back.usage == SubaccountUsage.development && back.labels == ["cost": "CC1"]);
}
