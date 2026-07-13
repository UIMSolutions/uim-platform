/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.application.usecases.manage.groups;
// import uim.platform.identity_directory.domain.entities.group;
// import uim.platform.identity_directory.domain.entities.user;
// import uim.platform.identity_directory.domain.entities.audit_event;

// import uim.platform.identity_directory.domain.ports.repositories.groups;
// import uim.platform.identity_directory.domain.ports.repositories.users;
// import uim.platform.identity_directory.domain.ports.repositories.audits;


import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// Application use case: SCIM 2.0 group management.
class ManageGroupsUseCase { // TODO: UIMUseCase {
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
    if (groupRepo.existsByDisplayName(req.tenantId, req.displayName))
      return GroupResponse("", "IDGroup with this displayName already exists");

    auto group = IDGroup(req.tenantId);
    group.externalId = req.externalId;
    group.displayName = req.displayName;
    group.description = req.description;
    group.members = req.members;
    group.schemas = ["urn:ietf:params:scim:schemas:core:2.0:IDGroup"];

    groupRepo.save(group);

    // Update user groupIds for initial members
    foreach (m; req.members) {
      if (m.type == "IDUser") {
        auto user = userRepo.findById(group.tenantId, m.value);
        if (!user.isNull) {
          user.groupIds ~= group.id;
          userRepo.update(user);
        }
      }
    }

    auditRepo.save(AuditEvent(randomUUID().toString(), req.tenantId,
        AuditEventType.groupCreated, "system", "System", group.id, "IDGroup",
        "IDGroup created: " ~ req.displayName, "", "", null, now,));

    return GroupResponse(group.id.value, "");
  }

  /// Get group by ID.
  IDGroup getGroup(GroupId id) {
    return groupRepo.findById(tenantId, id);
  }

  /// List groups for a tenant.
  IDGroup[] listGroups(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return groupRepo.findByTenant(tenantId, offset, limit);
  }

  /// Update group metadata.
  CommandResult updateGroup(UpdateGroupRequest req) {
    auto group = groupRepo.findById(req.tenantId, req.groupId);
    if (group.isNull)
      return CommandResult(false, "", "IDGroup not found");

    if (req.displayName.length > 0)
      group.displayName = req.displayName;
    if (req.description.length > 0)
      group.description = req.description;

    group.updatedAt = currentTimestamp();
    groupRepo.update(group);

    auditRepo.save(AuditEvent(randomUUID().toString(), group.tenantId,
        AuditEventType.groupUpdated, "system", "System", req.groupId, "IDGroup",
        "IDGroup updated", "", "", null, Clock.currStdTime(),));

    return CommandResult(true, req.groupId.value, "");
  }

  /// Add a member to a group.
  CommandResult addMember(AddMemberRequest req) {
    auto group = groupRepo.findById(req.tenantId, req.groupId);
    if (group.isNull)
      return CommandResult(false, "", "IDGroup not found");

    // Check if already a member
    if (group.hasMember(req.memberId))
      return CommandResult(false, "", "Already a member");

    group.members ~= GroupMember(req.memberId, req.memberType, req.display);
    group.updatedAt = currentTimestamp();
    groupRepo.update(group);

    // Update user's groupIds
    if (req.memberType == "IDUser") {
      auto user = userRepo.findById(req.memberId);
      if (user != IDUser.init) {
        user.groupIds ~= req.groupId;
        userRepo.update(user);
      }
    }

    auditRepo.save(AuditEvent(randomUUID().toString(), group.tenantId,
        AuditEventType.memberAdded, "system", "System", req.groupId, "IDGroup",
        "Member added: " ~ req.memberId, "", "", null, Clock.currStdTime(),));

    return CommandResult(true, req.groupId.value, "Member added successfully.");
  }

  /// Remove a member from a group.
  CommandResult removeMember(RemoveMemberRequest req) {
    auto group = groupRepo.findById(req.tenantId, req.groupId);
    if (group.isNull)
      return CommandResult(false, "", "IDGroup not found");

    auto newMembers = group.members.filter!(m => m.value != req.memberId).array.toJson;
    if (newMembers.length == group.members.length)
      return CommandResult(false, "", "Member not found in group");

    group.members = newMembers;
    group.updatedAt = currentTimestamp();
    groupRepo.update(group);

    // Update user's groupIds
    auto user = userRepo.findById(req.tenantId, req.memberId);
    if (!user.isNull) {
      user.groupIds = user.groupIds.filter!(g => g != req.groupId).array.toJson;
      userRepo.update(user);
    }

    auditRepo.save(AuditEvent(randomUUID().toString(), group.tenantId,
        AuditEventType.memberRemoved, "system", "System", req.groupId, "IDGroup",
        "Member removed: " ~ req.memberId, "", "", null, Clock.currStdTime(),));

    return CommandResult(true, req.groupId.value, "Member removed successfully.");
  }

  /// Delete a group.
  CommandResult deleteGroup(TenantId tenantId, GroupId id) {
    auto group = groupRepo.findById(tenantId, id);
    if (group.isNull)
      return CommandResult(false, "", "IDGroup not found");

    // Remove group from all member users
    foreach (m; group.members) {
      if (m.type == "IDUser") {
        auto user = userRepo.findById(tenantId, m.value);
        if (!user.isNull) {
          user.groupIds = user.groupIds.filter!(g => g != id).array.toJson;
          userRepo.update(user);
        }
      }
    }

    groupRepo.remove(group);

    auditRepo.save(AuditEvent(randomUUID().toString(), group.tenantId,
        AuditEventType.groupDeleted, "system", "System", id, "IDGroup",
        "IDGroup deleted: " ~ group.displayName, "", "", null, Clock.currStdTime(),));

    return CommandResult(true, id.value, "IDGroup deleted successfully.");
  }
}
