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
  protected IUserAssignmentRepository repo;
  private IRoleCollectionRepository roleCollectionRepo;

  this(IUserAssignmentRepository repo, IRoleCollectionRepository roleCollectionRepo) {
    this.repo = repo;
    this.roleCollectionRepo = roleCollectionRepo;
  }

  UsecaseResult createAssignment(CreateUserAssignmentRequest r) {
    if (r.userId.isEmpty)
      return UsecaseResult(false, "", "userId is required");

    if (r.roleCollectionId.isEmpty)
      return UsecaseResult(false, "", "roleCollectionId is required");

    if (!roleCollectionRepo.existsById(r.tenantId, r.roleCollectionId))
      return UsecaseResult(false, "", "Role collection not found");

    import std.uuid : randomUUID;

    UserAssignment ua;
    ua.tenantId = r.tenantId;
    ua.id = generateId;
    ua.userId = r.userId;
    ua.userEmail = r.userEmail;
    ua.roleCollectionId = r.roleCollectionId;
    ua.origin = r.origin;
    ua.createdAt = currentTimestamp();

    repo.save(ua);
    return UsecaseResult(true, ua.id.value, "");
  }

  UsecaseResult deleteAssignment(TenantId tenantId, UserAssignmentId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return UsecaseResult(false, "", "User assignment not found");

    repo.remove(existing);
    return UsecaseResult(true, existing.id.value, "");
  }

  UserAssignment getAssignment(TenantId tenantId, UserAssignmentId id) {
    return repo.findById(tenantId, id);
  }

  UserAssignment[] listAssignments(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UserAssignment[] listAssignments(TenantId tenantId, UserId userId) {
    return repo.findByUser(tenantId, userId);
  }
}

///
unittest {
//    auto userAssignmentRepository = new UserAssignmentRepository();
//    auto roleCollectionRepository = new RoleCollectionRepository();
//    auto usecase = new ManageUserAssignmentsUseCase(userAssignmentRepository, roleCollectionRepository);
//    auto tenantId = TenantId("test-tenant");
//
//    // Test list
//    auto items = usecase.listAssignments(tenantId);
//    assert(items !is null);

}
