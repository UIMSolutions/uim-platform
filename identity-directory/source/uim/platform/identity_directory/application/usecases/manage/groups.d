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
      return GroupResponse("", "Group with this displayName already exists");

    auto group = IDGroup(req.tenantId);
    group.externalId = req.externalId;
    group.displayName = req.displayName;
    group.description = req.description;
    group.members = req.members;
    group.schemas = ["urn:ietf:params:scim:schemas:core:2.0:Group"];

    groupRepo.save(group);

    // Update user groupIds for initial members
    foreach (m; req.members) {
      if (m.type == "User") {
        auto user = userRepo.findById(group.tenantId, UserId(m.value));
        if (!user.isNull) {
          user.groupIds ~= group.id;
          userRepo.update(user);
        }
      }
    }

    auto event = AuditEvent(req.tenantId);
    event.id = randomUUID().toString();
    event.eventType = AuditEventType.groupCreated;
    event.actorId = "system";
    event.targetId = group.id.value;
    event.targetType = "Group";
    event.description = "Group created: " ~ req.displayName;
    event.details = null;
    // event.metadata = "";
    // event.context = null;
    event.timestamp = event.createdAt;

    auditRepo.save(event);

    return GroupResponse(group.id.value, "");
  }

  /// Get group by ID.
  IDGroup getGroup(TenantId tenantId, GroupId id) {
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
      return CommandResult(false, "", "Group not found");

    if (req.displayName.length > 0)
      group.displayName = req.displayName;

    if (req.description.length > 0)
      group.description = req.description;

    group.updatedAt = currentTimestamp();
    groupRepo.update(group);

    auto event = AuditEvent(req.tenantId);
    event.id = randomUUID().toString();
    event.eventType = AuditEventType.groupUpdated;
    event.actorId = "system";
    event.targetId = group.id.value;
    event.targetType = "Group";
    event.description = "Group updated: " ~ group.displayName;
    event.details = null;
    // event.metadata = "";
    // event.context = null;
    event.timestamp = event.createdAt;

    auditRepo.save(event);

    return CommandResult(true, req.groupId.value, "");
  }

  /// Add a member to a group.
  CommandResult addMember(AddMemberRequest req) {
    auto group = groupRepo.findById(req.tenantId, req.groupId);
    if (group.isNull)
      return CommandResult(false, "", "Group not found");

    // Check if already a member
    if (group.hasMember(req.memberId))
      return CommandResult(false, "", "Already a member");

    group.members ~= GroupMember(req.memberId, req.memberType, req.display);
    group.updatedAt = currentTimestamp();
    groupRepo.update(group);

    // Update user's groupIds
    if (req.memberType == "User") {
        auto user = userRepo.findById(group.tenantId, UserId(req.memberId));
        if (!user.isNull) {
          user.groupIds ~= req.groupId;
          userRepo.update(user);
      }
    }

    auto event = AuditEvent(req.tenantId);
    event.id = randomUUID().toString();
    event.eventType = AuditEventType.memberAdded;
    event.actorId = "system";
    event.targetId = req.groupId.value;
    event.targetType = "Group";
    event.description = "Member added: " ~ req.memberId;
    event.details = null;
    // event.metadata = "";
    // event.context = null;
    event.timestamp = event.createdAt;  

    auditRepo.save(event);

    return CommandResult(true, req.groupId.value, "Member added successfully.");
  }

  /// Remove a member from a group.
  CommandResult removeMember(RemoveMemberRequest req) {
    auto group = groupRepo.findById(req.tenantId, req.groupId);
    if (group.isNull)
      return CommandResult(false, "", "Group not found");

    auto newMembers = group.members.filter!(m => m.value != req.memberId).array;
    if (newMembers.length == group.members.length)
      return CommandResult(false, "", "Member not found in group");

    group.members = newMembers;
    group.updatedAt = currentTimestamp();
    groupRepo.update(group);

    // Update user's groupIds
    auto user = userRepo.findById(req.tenantId, UserId(req.memberId));
    if (!user.isNull) {
      user.groupIds = user.groupIds.filter!(gId => gId.value != group.id.value).array;
      userRepo.update(user);
    }

    auto event = AuditEvent(req.tenantId);
    event.id = randomUUID().toString();
    event.eventType = AuditEventType.memberRemoved;
    event.actorId = "system";
    event.targetId = req.groupId.value;
    event.targetType = "Group";
    event.description = "Member removed: " ~ req.memberId;
    event.details = null;
    // event.metadata = "";
    // event.context = null;
    event.timestamp = event.createdAt;

    auditRepo.save(event);
    return CommandResult(true, req.groupId.value, "Member removed successfully.");
  }

  /// Delete a group.
  CommandResult deleteGroup(TenantId tenantId, GroupId id) {
    auto group = groupRepo.findById(tenantId, id);
    if (group.isNull)
      return CommandResult(false, "", "Group not found");

    // Remove group from all member users
    foreach (m; group.members) {
      if (m.type == "User") {
        auto user = userRepo.findById(tenantId, UserId(m.value));
        if (!user.isNull) {
          user.groupIds = user.groupIds.filter!(gId => gId.value != id.value).array;
          userRepo.update(user);
        }
      }
    }

    groupRepo.remove(group);

    auto event = AuditEvent(tenantId);
    event.id = randomUUID().toString();
    event.eventType = AuditEventType.groupDeleted;
    event.actorId = "system";
    event.targetId = id.value;
    event.targetType = "Group";
    event.description = "Group deleted: " ~ group.displayName;
    // event.details = null;
    // event.metadata = "";
    // event.context = null;
    event.timestamp = event.createdAt;

    auditRepo.save(event);
    return CommandResult(true, id.value, "Group deleted successfully.");
  }
}
