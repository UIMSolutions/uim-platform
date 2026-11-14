/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.usecases.roles;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Roles and their user / group assignments.
interface IManageRolesUseCase : IManageResource!(PortalRole, PortalRoleId, CreateRoleRequest, UpdateRoleRequest) {
  UsecaseResult assignUser(TenantId tenantId, PortalRoleId id, string user, UserId actor);
  UsecaseResult unassignUser(TenantId tenantId, PortalRoleId id, string user, UserId actor);
  UsecaseResult assignGroup(TenantId tenantId, PortalRoleId id, string group, UserId actor);
  UsecaseResult unassignGroup(TenantId tenantId, PortalRoleId id, string group, UserId actor);
}
