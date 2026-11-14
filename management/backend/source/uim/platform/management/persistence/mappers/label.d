/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.persistence.mappers.label;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Converts between Label and its snapshot record.
struct LabelMapper {
  static Json toRecord(const Label e) {
    auto r = baseRecord(e);
    r["resourceType"] = enumName(e.resourceType);
    r["resourceId"] = e.resourceId;
    r["key"] = e.key;
    r["values"] = listToJson(e.values);
    return r;
  }

  static Label fromRecord(Json r) {
    Label e;
    readBase(e, r);
    e.resourceType = fieldEnum!LabeledResourceType(r, "resourceType", LabeledResourceType.subaccount);
    e.resourceId = fieldString(r, "resourceId");
    e.key = fieldString(r, "key");
    e.values = fieldStrings(r, "values");
    return e;
  }
}
