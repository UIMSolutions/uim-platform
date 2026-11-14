/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.role;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// A portal role. Content (sites, pages, catalogs, tiles, menu items) lists the
/// roles allowed to see it; users get roles directly or through groups.
struct PortalRole {
  mixin TenantEntity!PortalRoleId;

  string name;
  string description;
  RoleScope scope_ = RoleScope.site;
  string[] userIds;
  string[] groupIds;

  /// True if the user (or one of the groups) is assigned.
  bool isAssigned(string userId, const string[] groups) const {
    import std.algorithm : canFind, any;

    return (userId.length > 0 && userIds.canFind(userId)) || groups.any!(g => groupIds.canFind(g));
  }
}

///
unittest {
  auto r = PortalRole(TenantId("t"));
  r.userIds = ["jane"];
  r.groupIds = ["sales"];
  assert(r.isAssigned("jane", null));
  assert(r.isAssigned("bob", ["sales"]));
  assert(!r.isAssigned("bob", ["hr"]));
}
