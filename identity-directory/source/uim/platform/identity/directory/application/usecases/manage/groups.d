/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.application.usecases.manage.groups;
// import uim.platform.identity.directory.domain.entities.group;
// import uim.platform.identity.directory.domain.entities.user;
// import uim.platform.identity.directory.domain.entities.audit_event;

// import uim.platform.identity.directory.domain.ports.repositories.groups;
// import uim.platform.identity.directory.domain.ports.repositories.users;
// import uim.platform.identity.directory.domain.ports.repositories.audits;
// import uim.platform.identity.directory.application.dto;

import uim.platform.identity.directory;

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
    if (groupRepo.exitstByDisplayName(req.tenantId, req.displayName))
      return GroupResponse("", "IAMGroup with this displayName already exists");

    auto group = IAMGroup(req.tenantId);
    group.externalId = req.externalId;
    group.displayName = req.displayName;
    group.description = req.description;
    group.members = req.members;
    group.schemas = ["urn:ietf:params:scim:schemas:core:2.0:IAMGroup"];

    groupRepo.save(group);

    // Update user groupIds for initial members
    foreach (m; req.members) {
      if (m.type == "User") {
        auto user = userRepo.findById(m.value);
        if (!user.isNull) {
          user.groupIds ~= group.id;
          userRepo.update(user);
        }
      }
    }

    auditRepo.save(AuditEvent(randomUUID().toString(), req.tenantId,
        AuditEventType.groupCreated, "system", "System", groupId, "IAMGroup",
        "IAMGroup created: " ~ req.displayName, "", "", null, now,));

    return GroupResponse(groupId, "");
  }

  /// Get group by ID.
  IAMGroup getGroup(IAMGroupId id) {
    return groupRepo.findById(tenantId, id);
  }

  /// List groups for a tenant.
  IAMGroup[] listGroups(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return groupRepo.findByTenant(tenantId, offset, limit);
  }

  /// Update group metadata.
  CommandResult updateGroup(UpdateGroupRequest req) {
    auto group = groupRepo.findById(req.groupId);
    if (group.isNull)
      return CommandResult(false, "", "IAMGroup not found");

    if (req.displayName.length > 0)
      group.displayName = req.displayName;
    if (req.description.length > 0)
      group.description = req.description;

    group.updatedAt = currentTimestamp();
    groupRepo.update(group);

    auditRepo.save(AuditEvent(randomUUID().toString(), group.tenantId,
        AuditEventType.groupUpdated, "system", "System", req.groupId, "IAMGroup",
        "IAMGroup updated", "", "", null, Clock.currStdTime(),));

    return CommandResult(true, req.groupId.value, "");
  }

  /// Add a member to a group.
  CommandResult addMember(AddMemberRequest req) {
    auto group = groupRepo.findById(req.groupId);
    if (group.isNull)
      return CommandResult(false, "", "IAMGroup not found");

    // Check if already a member
    if (group.hasMember(req.memberId))
      return CommandResult(false, "", "Already a member");

    group.members ~= GroupMember(req.memberId, req.memberType, req.display);
    group.updatedAt = currentTimestamp();
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
        AuditEventType.memberAdded, "system", "System", req.groupId, "IAMGroup",
        "Member added: " ~ req.memberId, "", "", null, Clock.currStdTime(),));

    return CommandResult(true, req.groupId.value, "Member added successfully.");
  }

  /// Remove a member from a group.
  CommandResult removeMember(RemoveMemberRequest req) {
    auto group = groupRepo.findById(req.groupId);
    if (group.isNull)
      return CommandResult(false, "", "IAMGroup not found");

    auto newMembers = group.members.filter!(m => m.value != req.memberId).array.toJson;
    if (newMembers.length == group.members.length)
      return CommandResult(false, "", "Member not found in group");

    group.members = newMembers;
    group.updatedAt = currentTimestamp();
    groupRepo.update(group);

    // Update user's groupIds
    auto user = userRepo.findById(req.memberId);
    if (!user.isNull) {
      user.groupIds = user.groupIds.filter!(g => g != req.groupId).array.toJson;
      userRepo.update(user);
    }

    auditRepo.save(AuditEvent(randomUUID().toString(), group.tenantId,
        AuditEventType.memberRemoved, "system", "System", req.groupId, "IAMGroup",
        "Member removed: " ~ req.memberId, "", "", null, Clock.currStdTime(),));

    return CommandResult(true, req.groupId.value, "Member removed successfully.");
  }

  /// Delete a group.
  CommandResult deleteGroup(IAMGroupId id) {
    auto group = groupRepo.findById(tenantId, id);
    if (group.isNull)
      return CommandResult(false, "", "IAMGroup not found");

    // Remove group from all member users
    foreach (m; group.members) {
      if (m.type == "User") {
        auto user = userRepo.findById(m.value);
        if (!user.isNull) {
          user.groupIds = user.groupIds.filter!(g => g != id).array.toJson;
          userRepo.update(user);
        }
      }
    }

    groupRepo.remove(group);

    auditRepo.save(AuditEvent(randomUUID().toString(), group.tenantId,
        AuditEventType.groupDeleted, "system", "System", id, "IAMGroup",
        "IAMGroup deleted: " ~ group.displayName, "", "", null, Clock.currStdTime(),));

    return CommandResult(true, id.value, "IAMGroup deleted successfully.");
  }
}
