/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.application.usecases.manage.groups;
// import uim.platform.identity.authentication.domain.entities.group;
// import uim.platform.identity.authentication.domain.types;
// import uim.platform.identity.authentication.domain.ports.repositories.group;
// import uim.platform.identity.authentication.domain.ports.repositories.user;
// import uim.platform.identity.authentication.application.dto;
// 
// 
// 
// import std.algorithm : canFind, remove;
import uim.platform.identity.authentication;

// mixin(ShowModule!());
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
    auto group = IdaGroup(req.tenantId);
    group.name = req.name;
    group.description = req.description;
    group.memberUserIds = [];
        
    groupRepo.save(group);
    return GroupResponse(group.id.value, "");
  }

  IdaGroup getGroup(TenantId tenantId, GroupId id) {
    return groupRepo.findById(tenantId, id);
  }

  IdaGroup[] listGroups(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return groupRepo.findByTenant(tenantId, offset, limit);
  }

  CommandResult addMember(TenantId tenantId, GroupId groupId, UserId userId) {
    import uim.platform.identity.authentication.domain.entities.user : User;

    auto group = groupRepo.findById(tenantId, groupId);
    if (group == IdaGroup.init)
      return CommandResult(false, "", "IdaGroup not found");

    auto user = userRepo.findById(userId);
    if (user == User.init)
      return CommandResult(false, "", "User not found");

    if (!group.memberUserIds.canFind(userId)) {
      group.memberUserIds ~= userId;
      group.updatedAt = currentTimestamp();
      groupRepo.update(group);

      // Also update user's groupIds
      if (!user.groupIds.canFind(groupId)) {
        user.groupIds ~= groupId;
        userRepo.update(user);
      }
    }
    return CommandResult(true, group.id.value, "");
  }

  CommandResult removeMember(TenantId tenantId, GroupId groupId, UserId userId) {
    auto group = groupRepo.findById(tenantId, groupId);
    if (group == IdaGroup.init)
      return CommandResult(false, "", "IdaGroup not found");

    string[] updated;
    foreach (mid; group.memberUserIds) {
      if (mid != userId)
        updated ~= mid;
    }
    group.memberUserIds = updated;
    group.updatedAt = currentTimestamp();
    groupRepo.update(group);
    return CommandResult(true, group.id.value, "");
  }

  CommandResult deleteGroup(TenantId tenantId, GroupId id) {
    auto group = groupRepo.findById(tenantId, id);
    if (group == IdaGroup.init)
      return CommandResult(false, "", "IdaGroup not found");  

    groupRepo.remove(group);
    return CommandResult(true, group.id.value, "");
  }
}
