/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.manage.groups;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Group management. Membership is kept consistent on both sides
/// (IAGroup.memberUserIds and IAUser.groupIds).
class ManageGroupsUseCase : IManageGroupsUseCase {
  protected IGroupRepository repo;
  protected IUserRepository users;

  this(IGroupRepository repo, IUserRepository users) {
    this.repo = repo;
    this.users = users;
  }

  IAGroup[] listGroups(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  IAGroup getGroup(TenantId tenantId, GroupId id) {
    return repo.findById(tenantId, id);
  }

  IAUser[] listMembers(TenantId tenantId, GroupId id) {
    return users.findByGroupId(tenantId, id);
  }

  UsecaseResult createGroup(GroupDTO dto) {
    if (!dto.groupId.isNull && repo.existsById(dto.tenantId, dto.groupId))
      return conflict("Group '" ~ dto.groupId.value ~ "' already exists");
    auto group = newEntity!IAGroup(dto.tenantId, dto.groupId, dto.createdBy);
    group.name = dto.name.strip;
    group.description = dto.description;
    auto errors = IdentityValidator.validate(group);
    if (errors.length)
      return invalid(errors);
    if (repo.existsByName(dto.tenantId, group.name))
      return conflict("A group named '" ~ group.name ~ "' already exists");
    repo.save(group);
    return created(group.id.value, "Group created");
  }

  UsecaseResult updateGroup(GroupDTO dto) {
    auto group = repo.findById(dto.tenantId, dto.groupId);
    if (group.isNull)
      return notFound("Group", dto.groupId.value);
    auto newName = dto.name.strip;
    if (newName.length && newName != group.name && repo.existsByName(dto.tenantId, newName))
      return conflict("A group named '" ~ newName ~ "' already exists");
    assignIf(group.name, newName);
    group.description = dto.description;
    touch(group, dto.updatedBy);
    repo.update(group);
    return succeeded(group.id.value, "Group updated");
  }

  UsecaseResult addMember(TenantId tenantId, GroupId groupId, UserId userId) {
    auto group = repo.findById(tenantId, groupId);
    if (group.isNull)
      return notFound("Group", groupId.value);
    auto user = users.findById(tenantId, userId);
    if (user.isNull)
      return notFound("User", userId.value);

    if (!group.hasMember(userId)) {
      group.memberUserIds ~= userId;
      group.update();
      repo.update(group);
    }
    if (!user.isMemberOf(groupId)) {
      user.groupIds ~= groupId;
      users.update(user);
    }
    return succeeded(group.id.value, "Member added");
  }

  UsecaseResult removeMember(TenantId tenantId, GroupId groupId, UserId userId) {
    auto group = repo.findById(tenantId, groupId);
    if (group.isNull)
      return notFound("Group", groupId.value);
    if (!group.hasMember(userId))
      return notFound("Member", userId.value);

    group.memberUserIds = group.memberUserIds.filter!(m => m != userId).array;
    group.update();
    repo.update(group);

    auto user = users.findById(tenantId, userId);
    if (!user.isNull && user.isMemberOf(groupId)) {
      user.groupIds = user.groupIds.filter!(g => g != groupId).array;
      users.update(user);
    }
    return succeeded(group.id.value, "Member removed");
  }

  UsecaseResult deleteGroup(TenantId tenantId, GroupId id) {
    auto group = repo.findById(tenantId, id);
    if (group.isNull)
      return notFound("Group", id.value);
    foreach (user; users.findByGroupId(tenantId, id)) {
      user.groupIds = user.groupIds.filter!(g => g != id).array;
      users.update(user);
    }
    repo.remove(group);
    return succeeded(id.value, "Group deleted");
  }
}

///
unittest {
  mixin(ShowTest!("ManageGroupsUseCase"));

  auto users = new UserRepository();
  auto uc = new ManageGroupsUseCase(new GroupRepository(), users);
  auto t = TenantId("t1");
  auto user = IAUser(t);
  user.userName = "jane";
  users.save(user);

  GroupDTO dto;
  dto.tenantId = t;
  dto.name = "admins";
  auto r = uc.createGroup(dto);
  assert(r.isSuccess);
  auto gid = GroupId(r.id);
  assert(uc.createGroup(dto).code == 409);

  assert(uc.addMember(t, gid, user.id).isSuccess);
  assert(uc.addMember(t, gid, user.id).isSuccess); // idempotent
  assert(uc.getGroup(t, gid).memberUserIds.length == 1);
  assert(users.findById(t, user.id).isMemberOf(gid));
  assert(uc.listMembers(t, gid).length == 1);

  assert(uc.removeMember(t, gid, user.id).isSuccess);
  assert(!users.findById(t, user.id).isMemberOf(gid));
  assert(uc.removeMember(t, gid, user.id).code == 404);

  assert(uc.addMember(t, gid, user.id).isSuccess);
  assert(uc.deleteGroup(t, gid).isSuccess);
  assert(users.findById(t, user.id).groupIds.length == 0);
}
