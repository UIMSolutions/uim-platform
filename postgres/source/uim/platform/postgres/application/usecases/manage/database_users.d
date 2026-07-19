/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.application.usecases.manage.database_users;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class ManageDatabaseUsersUseCase {
    private DatabaseUserRepository repo;

    this(DatabaseUserRepository repo) { this.repo = repo; }

    DatabaseUser getDatabaseUser(TenantId tenantId, DatabaseUserId id) {
        return repo.findById(tenantId, id);
    }

    DatabaseUser[] listDatabaseUsers(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DatabaseUser[] listByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    CommandResult createDatabaseUser(DatabaseUserDTO dto) {
        if (repo.usernameExists(dto.tenantId, dto.instanceId, dto.username))
            return CommandResult(false, "", "Username already exists on this instance");

        auto e = DatabaseUser(dto.tenantId); //, UserId("test-user"));
        e.id = dto.databaseUserId;
        e.instanceId = dto.instanceId;
        e.username = dto.username;
        e.roles = dto.roles;
        e.status = UserStatus.active;

        if (e.instanceId.value.length == 0 || e.username.isEmpty)
            return CommandResult(false, "", "instanceId and username are required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateDatabaseUser(DatabaseUserDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.databaseUserId);
        if (existing.isNull)
            return CommandResult(false, "", "Database user not found");
        if (dto.roles.length > 0) existing.roles = dto.roles;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteDatabaseUser(TenantId tenantId, DatabaseUserId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Database user not found");
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
