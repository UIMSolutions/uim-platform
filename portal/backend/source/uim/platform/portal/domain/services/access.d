/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Role based visibility of content.
module uim.platform.portal.domain.services.access;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// The roles of one user plus whether role checks apply at all.
struct AccessScope {
  /// false = design time: everything is visible (administration, CDM documents).
  bool restricted;
  PortalRoleId[] roles;

  /// Design time scope (no filtering).
  static AccessScope designTime() {
    return AccessScope(false, null);
  }

  /// Runtime scope of a user holding `roles`.
  static AccessScope forRoles(PortalRoleId[] roles) {
    return AccessScope(true, roles);
  }

  /// Content without allowed roles is public; otherwise the user needs one of them.
  bool allows(const PortalRoleId[] allowedRoleIds) const {
    if (!restricted || allowedRoleIds.length == 0)
      return true;
    foreach (r; allowedRoleIds)
      if (roles.canFind(r))
        return true;
    return false;
  }
}

/// The roles assigned to a user directly or through one of the groups.
PortalRoleId[] rolesOfUser(const PortalRole[] roles, string userId, const string[] groups) {
  PortalRoleId[] result;
  foreach (r; roles)
    if (r.isAssigned(userId, groups))
      result ~= r.id;
  return result;
}

///
unittest {
  auto admin = PortalRole(TenantId("t"), PortalRoleId("admin"));
  admin.userIds = ["jane"];
  auto sales = PortalRole(TenantId("t"), PortalRoleId("sales"));
  sales.groupIds = ["emea-sales"];

  auto jane = AccessScope.forRoles(rolesOfUser([admin, sales], "jane", null));
  assert(jane.allows(null));
  assert(jane.allows([PortalRoleId("admin")]));
  assert(!jane.allows([PortalRoleId("sales")]));
  assert(AccessScope.forRoles(rolesOfUser([admin, sales], "bob", ["emea-sales"])).allows([PortalRoleId("sales")]));
  assert(AccessScope.designTime.allows([PortalRoleId("x")]));
}
