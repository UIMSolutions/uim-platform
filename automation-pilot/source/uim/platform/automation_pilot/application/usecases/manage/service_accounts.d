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

    ServiceAccount getServiceAccount(TenantId tenantId, ServiceAccountId id) {
        return repo.findById(tenantId, id);
    }

    ServiceAccount[] listServiceAccounts(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createServiceAccount(ServiceAccountDTO dto) {
        ServiceAccount sa;
        sa.initEntity(dto.tenantId, dto.createdBy);
        
        sa.id = ServiceAccountId(dto.id);
        sa.name = dto.name;
        sa.description = dto.description;
        sa.clientId = dto.clientId;
        sa.permissions = dto.permissions;
        sa.expiresAt = dto.expiresAt;
        if (!AutomationValidator.isValidServiceAccount(sa))
            return CommandResult(false, "", "Invalid service account data");

        repo.save(sa);
        return CommandResult(true, sa.id.value, "");
    }

    CommandResult updateServiceAccount(ServiceAccountDTO dto) {
        auto existing = repo.findById(dto.tenantId, ServiceAccountId(dto.id));
        if (existing.isNull)
            return CommandResult(false, "", "Service account not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.permissions.length > 0) existing.permissions = dto.permissions;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteServiceAccount(TenantId tenantId, ServiceAccountId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Service account not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
