/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.persistence.mappers.environment;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Converts between Environment and its snapshot record.
struct EnvironmentMapper {
  static Json toRecord(const Environment e) {
    auto r = baseRecord(e);
    r["globalAccountId"] = e.globalAccountId.value;
    r["subaccountId"] = e.subaccountId.value;
    r["name"] = e.name;
    r["description"] = e.description;
    r["environmentType"] = enumName(e.environmentType);
    r["status"] = enumName(e.status);
    r["planName"] = e.planName;
    r["landscapeLabel"] = e.landscapeLabel;
    r["technicalKey"] = e.technicalKey;
    r["dashboardUrl"] = e.dashboardUrl;
    r["platformRegion"] = e.platformRegion;
    r["services"] = listToJson(e.services);
    r["memoryQuotaMb"] = e.memoryQuotaMb;
    r["routeQuota"] = e.routeQuota;
    r["serviceQuota"] = e.serviceQuota;
    r["parameters"] = propertiesToJson(e.parameters);
    r["labels"] = propertiesToJson(e.labels);
    return r;
  }

  static Environment fromRecord(Json r) {
    Environment e;
    readBase(e, r);
    e.globalAccountId = GlobalAccountId(fieldString(r, "globalAccountId"));
    e.subaccountId = SubaccountId(fieldString(r, "subaccountId"));
    e.name = fieldString(r, "name");
    e.description = fieldString(r, "description");
    e.environmentType = fieldEnum!EnvironmentType(r, "environmentType", EnvironmentType.cloudFoundry);
    e.status = fieldEnum!EnvironmentStatus(r, "status", EnvironmentStatus.creating);
    e.planName = fieldString(r, "planName");
    e.landscapeLabel = fieldString(r, "landscapeLabel");
    e.technicalKey = fieldString(r, "technicalKey");
    e.dashboardUrl = fieldString(r, "dashboardUrl");
    e.platformRegion = fieldString(r, "platformRegion");
    e.services = fieldStrings(r, "services");
    e.memoryQuotaMb = fieldInt(r, "memoryQuotaMb");
    e.routeQuota = fieldInt(r, "routeQuota");
    e.serviceQuota = fieldInt(r, "serviceQuota");
    e.parameters = fieldMap(r, "parameters");
    e.labels = fieldMap(r, "labels");
    return e;
  }
}
