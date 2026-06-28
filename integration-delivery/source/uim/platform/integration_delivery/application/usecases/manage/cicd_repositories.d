/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.application.usecases.manage.cicd_repositories;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

class ManageCicdRepositoriesUseCase {
    private CicdRepositoryRepository repo;

    this(CicdRepositoryRepository repo) {
        this.repo = repo;
    }

    CicdRepository getCicdRepository(TenantId tenantId, CicdRepositoryId id) {
        return repo.findById(tenantId, id);
    }

    CicdRepository[] listCicdRepositories(TenantId tenantId) {
        return repo.find(tenantId);
    }

    CicdRepository[] listByStatus(TenantId tenantId, RepositoryStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createCicdRepository(CicdRepositoryDTO dto) {
        CicdRepository r;
        r.initEntity(dto.tenantId, dto.createdBy);
        r.id = dto.cicdRepositoryId;
        r.name = dto.name;
        r.description = dto.description;
        r.url = dto.url;
        r.credentialId = dto.credentialId;
        r.defaultBranch = dto.defaultBranch.length > 0 ? dto.defaultBranch : "main";
        r.webhookEnabled = dto.webhookEnabled;
        r.status = RepositoryStatus.active;

        if (!CicdValidator.isValidRepository(r))
            return CommandResult(false, "", "Invalid repository data: name and url required");

        repo.save(r);
        return CommandResult(true, r.id.value, "");
    }

    CommandResult updateCicdRepository(CicdRepositoryDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.cicdRepositoryId);
        if (existing.isNull)
            return CommandResult(false, "", "Repository not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.url.length > 0) existing.url = dto.url;
        if (dto.defaultBranch.length > 0) existing.defaultBranch = dto.defaultBranch;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteCicdRepository(TenantId tenantId, CicdRepositoryId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Repository not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
