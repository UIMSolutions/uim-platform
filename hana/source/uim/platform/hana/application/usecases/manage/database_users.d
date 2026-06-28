/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.application.usecases.manage.database_users;
// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.database_user;
// import uim.platform.hana.domain.ports.repositories.database_users;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

// mixin(ShowModule!());

@safe:
class ManageDatabaseUsersUseCase { // TODO: UIMUseCase {
  private DatabaseUserRepository repo;

  this(DatabaseUserRepository repo) {
    this.repo = repo;
  }

  CommandResult createDatabaseUser(CreateDatabaseUserRequest r) {
    if (r.isNull || r.userName.length == 0)
      return CommandResult(false, "", "User ID and username are required");

    if (repo.existsById(r.id))
      return CommandResult(false, "", "Database user already exists");

    DatabaseUser u;
    u.id = r.id;
    u.initEntity(r.tenantId);
    u.instanceId = r.instanceId;
    u.userName = r.userName;
    u.status = UserStatus.active;
    u.defaultSchema = r.defaultSchema;
    u.isRestricted = r.isRestricted;
    u.forcePasswordChange = r.forcePasswordChange;

    repo.save(u);
    return CommandResult(true, u.id.value, "");
  }

  DatabaseUser getDatabaseUser(TenantId tenantId, DatabaseUserId id) {
    return repo.find(tenantId, id);
  }

  DatabaseUser[] listDatabaseUsers(TenantId tenantId) {
    return repo.find(tenantId);
  }

  CommandResult updateDatabaseUser(UpdateDatabaseUserRequest r) {
    auto user = repo.find(r.tenantId, r.id);
    if (user.isNull)
      return CommandResult(false, "", "Database user not found");

    user.defaultSchema = r.defaultSchema;
    user.isRestricted = r.isRestricted;
    user.forcePasswordChange = r.forcePasswordChange;

    
    user.updatedAt = currentTimestamp;

    repo.update(user);
    return CommandResult(true, user.id.value, "");
  }

  CommandResult deleteDatabaseUser(TenantId tenantId, DatabaseUserId id) {
    auto user = repo.find(tenantId, id);
    if (user.isNull)
      return CommandResult(false, "", "Database user not found");

    repo.remove(user);
    return CommandResult(true, user.id.value, "");
  }

  size_t countDatabaseUsers(TenantId tenantId) {
    return repo.count(tenantId);
  }
}
