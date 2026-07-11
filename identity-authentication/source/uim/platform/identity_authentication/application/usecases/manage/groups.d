/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.manage.groups;
// import uim.platform.identity_authentication.domain.entities.group;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.group;
// import uim.platform.identity_authentication.domain.ports.repositories.user;
// import uim.platform.identity_authentication.application.dto;
// 
// 
// 
// import std.algorithm : canFind, remove;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Application use case: group management (CRUD + membership).
class ManageGroupsUseCase { // TODO: UIMUseCase {
  private GroupRepository groupRepo;
  private UserRepository userRepo;

  this(GroupRepository groupRepo, UserRepository userRepo) {
    this.groupRepo = groupRepo;
    this.userRepo = userRepo;
  }

  GroupResponse createGroup(CreateGroupRequest req) {
    auto group = IAGroup(req.tenantId);
    group.name = req.name;
    group.description = req.description;
    group.memberUserIds = [];
        
    groupRepo.save(group);
    return GroupResponse(group.id.value, "");
  }

  IAGroup getGroup(TenantId tenantId, GroupId id) {
    return groupRepo.findById(tenantId, id);
  }

  IAGroup[] listGroups(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return groupRepo.findByTenant(tenantId, offset, limit);
  }

  CommandResult addMember(TenantId tenantId, GroupId groupId, UserId userId) {
    import uim.platform.identity_authentication.domain.entities.user : IAUser;

    auto group = groupRepo.findById(tenantId, groupId);
    if (group.isNull)
      return CommandResult(false, "", "IAGroup not found");

    auto user = userRepo.findById(tenantId, userId);
    if (user.isNull)
      return CommandResult(false, "", "IAUser not found");

    if (!group.memberUserIds.hasUserId(userId)) {
      group.memberUserIds ~= userId;
      group.updatedAt = currentTimestamp();
      groupRepo.update(group);

      // Also update user's groupIds
      if (!user.groupIds.canFind(groupId)) {
        user.groupIds ~= groupId.value;
        userRepo.update(user);
      }
    }
    return CommandResult(true, group.id.value, "");
  }

  CommandResult removeMember(TenantId tenantId, GroupId groupId, UserId userId) {
    auto group = groupRepo.findById(tenantId, groupId);
    if (group.isNull)
      return CommandResult(false, "", "IAGroup not found");

    string[] updated;
    foreach (mid; group.memberUserIds) {
      if (mid != userId.value)
        updated ~= mid;
    }
    group.memberUserIds = updated;
    group.updatedAt = currentTimestamp();
    groupRepo.update(group);
    return CommandResult(true, group.id.value, "");
  }

  CommandResult deleteGroup(TenantId tenantId, GroupId id) {
    auto group = groupRepo.findById(tenantId, id);
    if (group.isNull)
      return CommandResult(false, "", "IAGroup not found");  

    groupRepo.remove(group);
    return CommandResult(true, group.id.value, "");
  }
}
