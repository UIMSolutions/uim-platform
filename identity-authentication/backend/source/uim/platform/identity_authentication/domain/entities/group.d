/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.group;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Group for organizing users (used by policies and risk rules).
struct IAGroup {
  mixin TenantEntity!GroupId;

  string name;
  string description;
  UserId[] memberUserIds;

  bool hasMember(UserId userId) const {
    return memberUserIds.canFind(userId);
  }

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("memberCount", memberUserIds.length)
      .set("memberUserIds", memberUserIds.map!(id => Json(id.value)).array.toJson);
  }
}
