/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.application.usecases.manage.user_assignments;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

class ManageUserAssignmentsUseCase {
  private UserAssignmentRepository repo;
  private RoleCollectionRepository roleCollectionRepo;

  this(UserAssignmentRepository repo, RoleCollectionRepository roleCollectionRepo) {
    this.repo = repo;
    this.roleCollectionRepo = roleCollectionRepo;
  }

  CommandResult createAssignment(CreateUserAssignmentRequest r) {
    if (r.userId.isEmpty)
      return CommandResult(false, "", "userId is required");

    if (r.roleCollectionId.isEmpty)
      return CommandResult(false, "", "roleCollectionId is required");

    if (!roleCollectionRepo.existsById(r.tenantId, r.roleCollectionId))
      return CommandResult(false, "", "Role collection not found");

    import std.uuid : randomUUID;

    UserAssignment ua;
    ua.tenantId = r.tenantId;
    ua.id = randomUUID().toString();
    ua.userId = r.userId;
    ua.userEmail = r.userEmail;
    ua.roleCollectionId = r.roleCollectionId;
    ua.origin = r.origin;
    ua.createdAt = currentTimestamp();

    repo.save(ua);
    return CommandResult(true, ua.id.value, "");
  }

  CommandResult deleteAssignment(TenantId tenantId, UserAssignmentId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "User assignment not found");

    repo.remove(existing);
    return CommandResult(true, existing.id.value, "");
  }

  UserAssignment getAssignment(TenantId tenantId, UserAssignmentId id) {
    return repo.findById(tenantId, id);
  }

  UserAssignment[] listAssignments(TenantId tenantId) {
    return repo.find(tenantId);
  }

  UserAssignment[] listAssignments(TenantId tenantId, UserId userId) {
    return repo.findByUser(tenantId, userId);
  }
}
