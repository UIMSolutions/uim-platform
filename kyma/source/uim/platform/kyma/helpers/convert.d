/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.helpers.convert;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

ApiRuleEntryDto[] toRuleEntries(Json json) {
    if (!json.isObject)
      return null;

    if (!("rules" in json))
      return null;

    auto value = json["rules"];
    if (!value.isArray)
      return null;

    ApiRuleEntryDto[] entries;
    foreach (item; value.toArray) {
      ApiRuleEntryDto entry;
      entry.path = item.getString("path");
      entry.methods = getStringArray(item, "methods");
      entry.accessStrategy = item.getString("accessStrategy");
      entry.requiredScopes = getStringArray(item, "requiredScopes");
      entry.audiences = getStringArray(item, "audiences");
      entry.trustedIssuers = getStringArray(item, "trustedIssuers");
      entries ~= entry;
    }
    return entries;
  }

    AppApiEntryDto[] toApis(Json json) {
    if (!json.isObject)
      return null;

    if (!("apis" in json))
      return null;

    auto value = json["apis"];
    if (!value.isArray)
      return null;
      
      AppApiEntryDto[] entries;
    foreach (item; value.toArray) {
      AppApiEntryDto entry;
      entry.name = item.getString("name");
      entry.description = item.getString("description");
      entry.targetUrl = item.getString("targetUrl");
      entry.specUrl = item.getString("specUrl");
      entry.authType = item.getString("authType");
      entries ~= entry;
    }
    return entries;
  }