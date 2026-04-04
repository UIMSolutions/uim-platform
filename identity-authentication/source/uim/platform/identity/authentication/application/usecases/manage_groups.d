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
// // import std.uuid;
// // import std.datetime.systime : Clock;
// // import std.algorithm : canFind, remove;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Application use case: group management (CRUD + membership).
class ManageGroupsUseCase : UIMUseCase {
  private GroupRepository groupRepo;
  private UserRepository userRepo;

  this(GroupRepository groupRepo, UserRepository userRepo)
  {
    this.groupRepo = groupRepo;
    this.userRepo = userRepo;
  }

  GroupResponse createGroup(CreateGroupRequest req)
  {
    auto now = Clock.currStdTime();
    auto group = IdaGroup(randomUUID().toString(), req.tenantId, req.name,
        req.description, [], now, now);
    groupRepo.save(group);
    return GroupResponse(group.id, "");
  }

  IdaGroup getGroup(GroupId id)
  {
    return groupRepo.findById(id);
  }

  IdaGroup[] listGroups(TenantId tenantId, uint offset = 0, uint limit = 100)
  {
    return groupRepo.findByTenant(tenantId, offset, limit);
  }

  string addMember(GroupId groupId, UserId userId)
  {
    import uim.platform.identity_authentication.domain.entities.user : User;

    auto group = groupRepo.findById(groupId);
    if (group == IdaGroup.init)
      return "IdaGroup not found";

    auto user = userRepo.findById(userId);
    if (user == User.init)
      return "User not found";

    if (!group.memberUserIds.canFind(userId))
    {
      group.memberUserIds ~= userId;
      group.updatedAt = Clock.currStdTime();
      groupRepo.update(group);

      // Also update user's groupIds
      if (!user.groupIds.canFind(groupId))
      {
        user.groupIds ~= groupId;
        userRepo.update(user);
      }
    }
    return "";
  }

  string removeMember(GroupId groupId, UserId userId)
  {
    auto group = groupRepo.findById(groupId);
    if (group == IdaGroup.init)
      return "IdaGroup not found";

    string[] updated;
    foreach (mid; group.memberUserIds)
    {
      if (mid != userId)
        updated ~= mid;
    }
    group.memberUserIds = updated;
    group.updatedAt = Clock.currStdTime();
    groupRepo.update(group);
    return "";
  }

  string deleteGroup(GroupId id)
  {
    groupRepo.remove(id);
    return "";
  }
}
