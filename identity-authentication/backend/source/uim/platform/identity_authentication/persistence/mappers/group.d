/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.mappers.group;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// IAGroup ⇄ snapshot record.
struct GroupMapper {
  static Json toRecord(const IAGroup e) {
    auto r = baseRecord(e);
    r["name"] = e.name;
    r["description"] = e.description;
    r["memberUserIds"] = idsRecord(e.memberUserIds);
    return r;
  }

  static IAGroup fromRecord(Json r) {
    IAGroup e;
    readBase(e, r);
    e.name = fieldString(r, "name");
    e.description = fieldString(r, "description");
    e.memberUserIds = fieldIds!UserId(r, "memberUserIds");
    return e;
  }
}
