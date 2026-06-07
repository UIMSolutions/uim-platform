/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.helpers.convert;

import uim.platform.kyma;

// mixin(ShowModule!());

@safe:

ApiRuleEntryDto[] toRuleEntries(Json json) {
    ApiRuleEntryDto[] entries;

    foreach (item; json.getArray("rules")) {
      ApiRuleEntryDto entry;
      entry.path = item.getString("path");
      entry.methods = getStrings(item, "methods");
      entry.accessStrategy = item.getString("accessStrategy");
      entry.requiredScopes = getStrings(item, "requiredScopes");
      entry.audiences = getStrings(item, "audiences");
      entry.trustedIssuers = getStrings(item, "trustedIssuers");
      entries ~= entry;
    }

    return entries;
  }

    AppApiEntryDto[] toApis(Json json) {
      AppApiEntryDto[] entries;

    foreach (item; json.getArray("apis")) {
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