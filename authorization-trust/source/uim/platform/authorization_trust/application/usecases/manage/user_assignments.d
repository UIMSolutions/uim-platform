/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.application.usecases.manage.user_assignments;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class ManageUserAssignmentsUseCase {
  private UserAssignmentRepository repo;
  private RoleCollectionRepository roleCollectionRepo;

  this(UserAssignmentRepository repo, RoleCollectionRepository roleCollectionRepo) {
    this.repo             = repo;
    this.roleCollectionRepo = roleCollectionRepo;
  }

  CommandResult createUserAssignment(CreateUserAssignmentRequest r) {
    if (r.userId.length == 0)
      return CommandResult(false, "", "userId is required");
    if (r.roleCollectionId.length == 0)
      return CommandResult(false, "", "roleCollectionId is required");
    if (!roleCollectionRepo.existsById(r.tenantId, r.roleCollectionId))
      return CommandResult(false, "", "Role collection not found");

    import std.uuid : randomUUID;
    UserAssignmentEntity ua;
    ua.id               = randomUUID().toString();
    ua.userId           = r.userId;
    ua.userEmail        = r.userEmail;
    ua.roleCollectionId = r.roleCollectionId;
    ua.origin           = r.origin;
    ua.createdAt        = currentTimestamp();

    repo.save(ua);
    return CommandResult(true, ua.id, "");
  }

  CommandResult deleteUserAssignment(TenantId tenantId, UserAssignmentId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "User assignment not found");

    repo.remove(existing);
    return CommandResult(true, existing.id, "");
  }

  UserAssignmentEntity getUserAssignment(TenantId tenantId, UserAssignmentId id) {
    return repo.findById(tenantId, id);
  }

  UserAssignmentEntity[] listUserAssignments(TenantId tenantId, Tstring userId) {
    return repo.findByUserId(tenantId, userId);
  }
}
