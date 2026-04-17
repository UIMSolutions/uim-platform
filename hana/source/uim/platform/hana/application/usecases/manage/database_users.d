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

// import uim.platform.service;
// import std.conv : to;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageDatabaseUsersUseCase : UIMUseCase {
  private DatabaseUserRepository repo;

  this(DatabaseUserRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateDatabaseUserRequest r) {
    if (r.id.isEmpty || r.userName.length == 0)
      return CommandResult(false, "", "User ID and username are required");

    if (repo.existsById(r.id))
      return CommandResult(false, "", "Database user already exists");

    DatabaseUser u;
    u.id = r.id;
    u.tenantId = r.tenantId;
    u.instanceId = r.instanceId;
    u.userName = r.userName;
    u.status = UserStatus.active;
    u.defaultSchema = r.defaultSchema;
    u.isRestricted = r.isRestricted;
    u.forcePasswordChange = r.forcePasswordChange;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    u.createdAt = now;
    u.modifiedAt = now;

    repo.save(u);
    return CommandResult(true, u.id, "");
  }

  DatabaseUser getById(DatabaseUserId id) {
    return repo.findById(id);
  }

  DatabaseUser[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult update(UpdateDatabaseUserRequest r) {
    if (!repo.existsById(r.id))
      return CommandResult(false, "", "Database user not found");

    auto existing = repo.findById(r.id);
    existing.defaultSchema = r.defaultSchema;
    existing.isRestricted = r.isRestricted;
    existing.forcePasswordChange = r.forcePasswordChange;

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(DatabaseUserId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Database user not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
