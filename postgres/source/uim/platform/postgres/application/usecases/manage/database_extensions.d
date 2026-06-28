/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.application.usecases.manage.database_extensions;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class ManageDatabaseExtensionsUseCase {
    private DatabaseExtensionRepository repo;

    this(DatabaseExtensionRepository repo) { this.repo = repo; }

    DatabaseExtension getDatabaseExtension(TenantId tenantId, DatabaseExtensionId id) {
        return repo.find(tenantId, id);
    }

    DatabaseExtension[] listDatabaseExtensions(TenantId tenantId) {
        return repo.find(tenantId);
    }

    DatabaseExtension[] listByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    CommandResult createDatabaseExtension(DatabaseExtensionDTO dto) {
        if (repo.extensionExists(dto.tenantId, dto.instanceId, dto.extensionName))
            return CommandResult(false, "", "Extension already enabled on this instance");

        DatabaseExtension e;
        e.initEntity(dto.tenantId, dto.createdBy);
        e.id = dto.databaseExtensionId;
        e.instanceId = dto.instanceId;
        e.extensionName = dto.extensionName;
        e.extensionVersion = dto.extensionVersion;
        e.schema_ = dto.schema_;
        e.status = ExtensionStatus.enabled;

        if (e.instanceId.value.length == 0 || e.extensionName.length == 0)
            return CommandResult(false, "", "instanceId and extensionName are required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult deleteDatabaseExtension(TenantId tenantId, DatabaseExtensionId id) {
        auto existing = repo.find(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Extension not found");
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
