/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.service_accounts;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageServiceAccountsUseCase { // TODO: UIMUseCase {
    private ServiceAccountRepository repo;

    this(ServiceAccountRepository repo) {
        this.repo = repo;
    }

    ServiceAccount getById(ServiceAccountId id) {
        return repo.findById(id);
    }

    ServiceAccount[] list() {
        return repo.findAll();
    }

    ServiceAccount[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult create(ServiceAccountDTO dto) {
        ServiceAccount sa;
        sa.id = ServiceAccountId(dto.id);
        sa.tenantId = dto.tenantId;
        sa.name = dto.name;
        sa.description = dto.description;
        sa.clientId = dto.clientId;
        sa.permissions = dto.permissions;
        sa.expiresAt = dto.expiresAt;
        sa.createdBy = dto.createdBy;
        if (!AutomationValidator.isValidServiceAccount(sa))
            return CommandResult(false, "", "Invalid service account data");
        repo.save(sa);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ServiceAccountDTO dto) {
        if (!repo.existsById(ServiceAccountId(dto.id)))
            return CommandResult(false, "", "Service account not found");
        auto existing = repo.findById(ServiceAccountId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.permissions.length > 0) existing.permissions = dto.permissions;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ServiceAccountId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Service account not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
