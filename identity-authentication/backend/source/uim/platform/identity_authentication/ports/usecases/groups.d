/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.usecases.groups;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driving port: group management and membership.
interface IManageGroupsUseCase {
  IAGroup[] listGroups(TenantId tenantId);
  IAGroup getGroup(TenantId tenantId, GroupId id);
  IAUser[] listMembers(TenantId tenantId, GroupId id);

  UsecaseResult createGroup(GroupDTO dto);
  UsecaseResult updateGroup(GroupDTO dto);
  UsecaseResult addMember(TenantId tenantId, GroupId groupId, UserId userId);
  UsecaseResult removeMember(TenantId tenantId, GroupId groupId, UserId userId);
  UsecaseResult deleteGroup(TenantId tenantId, GroupId id);
}
