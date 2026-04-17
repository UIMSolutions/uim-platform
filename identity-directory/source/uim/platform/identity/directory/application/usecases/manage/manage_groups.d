/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.application.usecases.manage.manage_groups;

// import uim.platform.identity.directory.domain.entities.group;
// import uim.platform.identity.directory.domain.entities.user;
// import uim.platform.identity.directory.domain.entities.audit_event;
// import uim.platform.identity.directory.domain.types;
// import uim.platform.identity.directory.domain.ports.repositories.groups;
// import uim.platform.identity.directory.domain.ports.repositories.users;
// import uim.platform.identity.directory.domain.ports.repositories.audits;
// import uim.platform.identity.directory.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;
// import std.algorithm : filter, canFind;
// import std.array : array;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:

/// Application use case: SCIM 2.0 group management.
class ManageGroupsUseCase : UIMUseCase {
  private GroupRepository groupRepo;
  private UserRepository userRepo;
  private AuditRepository auditRepo;

  this(GroupRepository groupRepo, UserRepository userRepo, AuditRepository auditRepo) {
    this.groupRepo = groupRepo;
    this.userRepo = userRepo;
    this.auditRepo = auditRepo;
  }

  /// Create a new group.
  GroupResponse createGroup(CreateGroupRequest req) {
    auto existing = groupRepo.findByDisplayName(req.tenantId, req.displayName);
    if (existing != Group.init)
      return GroupResponse("", "Group with this displayName already exists");

    auto now = Clock.currStdTime();
    auto groupId = randomUUID();
    auto group = Group(groupId, req.tenantId, req.externalId, req.displayName, req.description,
        GroupType.standard, req.members,
        ["urn:ietf:params:scim:schemas:core:2.0:Group"], now, now,);
    groupRepo.save(group);

    // Update user groupIds for initial members
    foreach (m; req.members) {
      if (m.type == "User") {
        auto user = userRepo.findById(m.value);
        if (user != User.init)
        {
          user.groupIds ~= groupId;
          userRepo.update(user);
        }
      }
    }

    auditRepo.save(AuditEvent(randomUUID().toString(), req.tenantId,
        AuditEventType.groupCreated, "system", "System", groupId, "Group",
        "Group created: " ~ req.displayName, "", "", null, now,));

    return GroupResponse(groupId, "");
  }

  /// Get group by ID.
  Group getGroup(GroupId id) {
    return groupRepo.findById(id);
  }

  /// List groups for a tenant.
  Group[] listGroups(TenantId tenantId, uint offset = 0, uint limit = 100) {
    return groupRepo.findByTenant(tenantId, offset, limit);
  }

  /// Update group metadata.
  string updateGroup(UpdateGroupRequest req) {
    auto group = groupRepo.findById(req.groupId);
    if (group == Group.init)
      return "Group not found";

    if (req.displayName.length > 0)
      group.displayName = req.displayName;
    if (req.description.length > 0)
      group.description = req.description;

    group.updatedAt = Clock.currStdTime();
    groupRepo.update(group);

    auditRepo.save(AuditEvent(randomUUID().toString(), group.tenantId,
        AuditEventType.groupUpdated, "system", "System", req.groupId, "Group",
        "Group updated", "", "", null, Clock.currStdTime(),));

    return "";
  }

  /// Add a member to a group.
  string addMember(AddMemberRequest req) {
    auto group = groupRepo.findById(req.groupId);
    if (group == Group.init)
      return "Group not found";

    // Check if already a member
    if (group.hasMember(req.memberId))
      return "Already a member";

    group.members ~= GroupMember(req.memberId, req.memberType, req.display);
    group.updatedAt = Clock.currStdTime();
    groupRepo.update(group);

    // Update user's groupIds
    if (req.memberType == "User") {
      auto user = userRepo.findById(req.memberId);
      if (user != User.init) {
        user.groupIds ~= req.groupId;
        userRepo.update(user);
      }
    }

    auditRepo.save(AuditEvent(randomUUID().toString(), group.tenantId,
        AuditEventType.memberAdded, "system", "System", req.groupId, "Group",
        "Member added: " ~ req.memberId, "", "", null, Clock.currStdTime(),));

    return "";
  }

  /// Remove a member from a group.
  string removeMember(RemoveMemberRequest req) {
    auto group = groupRepo.findById(req.groupId);
    if (group == Group.init)
      return "Group not found";

    auto newMembers = group.members.filter!(m => m.value != req.memberId).array;
    if (newMembers.length == group.members.length)
      return "Member not found in group";

    group.members = newMembers;
    group.updatedAt = Clock.currStdTime();
    groupRepo.update(group);

    // Update user's groupIds
    auto user = userRepo.findById(req.memberId);
    if (user != User.init) {
      user.groupIds = user.groupIds.filter!(g => g != req.groupId).array;
      userRepo.update(user);
    }

    auditRepo.save(AuditEvent(randomUUID().toString(), group.tenantId,
        AuditEventType.memberRemoved, "system", "System", req.groupId, "Group",
        "Member removed: " ~ req.memberId, "", "", null, Clock.currStdTime(),));

    return "";
  }

  /// Delete a group.
  string deleteGroup(GroupId id) {
    auto group = groupRepo.findById(id);
    if (group == Group.init)
      return "Group not found";

    // Remove group from all member users
    foreach (m; group.members) {
      if (m.type == "User") {
        auto user = userRepo.findById(m.value);
        if (user != User.init)
        {
          user.groupIds = user.groupIds.filter!(g => g != id).array;
          userRepo.update(user);
        }
      }
    }

    groupRepo.remove(id);

    auditRepo.save(AuditEvent(randomUUID().toString(), group.tenantId,
        AuditEventType.groupDeleted, "system", "System", id, "Group",
        "Group deleted: " ~ group.displayName, "", "", null, Clock.currStdTime(),));

    return "";
  }
}
