/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.helpers.convert;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

ApiRuleEntryDto[] toRuleEntries(Json j) {
    if (!j.isObject)
      return null;

    if (!("rules" in j))
      return null;

    auto value = j["rules"];
    if (!value.isArray)
      return null;

    ApiRuleEntryDto[] entries;
    foreach (item; value) {
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