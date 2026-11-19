/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.domain.ports.usecases.groups;

import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// Application use case: SCIM 2.0 group management.
interface IManageGroupsUseCase {

  /// Create a new group.
  GroupResponse createGroup(CreateGroupRequest req);

  /// Get group by ID.
  IDGroup getGroup(TenantId tenantId, GroupId id);

  /// List groups for a tenant.
  IDGroup[] listGroups(TenantId tenantId, size_t offset = 0, size_t limit = 100);

  /// Update group metadata.
  UsecaseResult updateGroup(UpdateGroupRequest req);

  /// Add a member to a group.
  UsecaseResult addMember(AddMemberRequest req);

  /// Remove a member from a group.
  UsecaseResult removeMember(RemoveMemberRequest req);

  /// Delete a group.
  UsecaseResult deleteGroup(TenantId tenantId, GroupId id);

}
