/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.application.usecases.manage.repositories;

import uim.platform.dms_integration;

// mixin(ShowModule!());

@safe:

class ManageRepositoriesUseCase {
    private RepositoryRepository repo;

    this(RepositoryRepository repo) {
        this.repo = repo;
    }

    Repository_ getRepository(TenantId tenantId, RepositoryId id) {
        return repo.findById(tenantId, id);
    }

    Repository_[] listRepositories(TenantId tenantId) {
        return repo.find(tenantId);
    }

    Repository_[] listRepositoriesByStatus(TenantId tenantId, RepositoryStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    Repository_[] listRepositoriesByType(TenantId tenantId, RepositoryType repositoryType) {
        return repo.findByType(tenantId, repositoryType);
    }

    Repository_[] listDefaultRepositories(TenantId tenantId) {
        return repo.findDefault(tenantId);
    }

    CommandResult createRepository(RepositoryDTO dto) {
        Repository_ r;
        r.id = dto.repositoryId;
        r.tenantId = dto.tenantId;
        r.name = dto.name;
        r.description = dto.description;
        r.externalUrl = dto.externalUrl;
        r.cmisVersion = dto.cmisVersion;
        r.encryptionEnabled = dto.encryptionEnabled;
        r.capacityLimitBytes = dto.capacityLimitBytes;
        r.repositoryKey = dto.repositoryKey;
        r.externalRepositoryId = dto.externalRepositoryId;
        r.region = dto.region;
        r.isReadOnly = dto.isReadOnly;
        r.versioningEnabled = dto.versioningEnabled;
        r.fullTextSearchEnabled = dto.fullTextSearchEnabled;
        r.isDefault = dto.isDefault;
        r.createdBy = dto.createdBy;
        if (dto.repositoryType.length > 0) {
            
            try { r.repositoryType = dto.repositoryType.to!RepositoryType; } catch (Exception) {}
        }
        r.status = RepositoryStatus.provisioning;
        if (!DmsValidator.isValidRepository(r))
            return CommandResult(false, "", "Invalid repository data: name is required");
        repo.save(r);
        return CommandResult(true, r.id.value, "");
    }

    CommandResult updateRepository(RepositoryDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.repositoryId);
        if (existing.isNull)
            return CommandResult(false, "", "Repository not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.externalUrl.length > 0) existing.externalUrl = dto.externalUrl;
        if (dto.region.length > 0) existing.region = dto.region;
        existing.isReadOnly = dto.isReadOnly;
        existing.versioningEnabled = dto.versioningEnabled;
        existing.fullTextSearchEnabled = dto.fullTextSearchEnabled;
        existing.isDefault = dto.isDefault;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult activateRepository(TenantId tenantId, RepositoryId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Repository not found");
        existing.status = RepositoryStatus.active;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deactivateRepository(TenantId tenantId, RepositoryId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Repository not found");
        existing.status = RepositoryStatus.inactive;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteRepository(TenantId tenantId, RepositoryId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Repository not found");
        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
