/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.application.usecases.manage.credentials;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

class ManageCredentialsUseCase {
    private CredentialRepository repo;

    this(CredentialRepository repo) {
        this.repo = repo;
    }

    Credential getCredential(TenantId tenantId, CredentialId id) {
        return repo.find(tenantId, id);
    }

    Credential[] listCredentials(TenantId tenantId) {
        return repo.find(tenantId);
    }

    Credential[] listByStatus(TenantId tenantId, CredentialStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createCredential(CredentialDTO dto) {
        if (repo.nameExists(dto.tenantId, dto.name))
            return CommandResult(false, "", "Credential name already exists");

        Credential c;
        c.initEntity(dto.tenantId, dto.createdBy);
        c.id = dto.credentialId;
        c.name = dto.name;
        c.description = dto.description;
        c.username = dto.username;
        c.secretRef = dto.secretRef;
        c.target = dto.target;
        c.expiresAt = dto.expiresAt;
        c.status = CredentialStatus.active;

        if (!CicdValidator.isValidCredential(c))
            return CommandResult(false, "", "Invalid credential data");

        repo.save(c);
        return CommandResult(true, c.id.value, "");
    }

    CommandResult updateCredential(CredentialDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.credentialId);
        if (existing.isNull)
            return CommandResult(false, "", "Credential not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.username.length > 0) existing.username = dto.username;
        if (dto.target.length > 0) existing.target = dto.target;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteCredential(TenantId tenantId, CredentialId id) {
        auto existing = repo.find(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Credential not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
