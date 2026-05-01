/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage.manage_oauth_scopes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageOAuthScopesUseCase { // TODO: UIMUseCase {
    private OAuthScopeRepository repo;

    this(OAuthScopeRepository repo) {
        this.repo = repo;
    }

    OAuthScope getById(OAuthScopeId id) {
        return repo.findById(id);
    }

    OAuthScope[] list() {
        return repo.findAll();
    }

    OAuthScope[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    OAuthScope[] listByApplication(string applicationId) {
        return repo.findByApplication(applicationId);
    }

    CommandResult create(OAuthScopeDTO dto) {
        OAuthScope e;
        e.id = OAuthScopeId(dto.id);
        e.tenantId = dto.tenantId;
        e.applicationId = dto.applicationId;
        e.name = dto.name;
        e.description = dto.description;
        e.createdBy = dto.createdBy;
        auto error = OAuthValidator.validateOAuthScope(e);
        if (error.length > 0)
            return CommandResult(false, "", error);
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(OAuthScopeDTO dto) {
        if (!repo.existsById(OAuthScopeId(dto.id)))
            return CommandResult(false, "", "OAuth scope not found");
        auto existing = repo.findById(OAuthScopeId(dto.id));
        existing.name = dto.name;
        existing.description = dto.description;
        existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(OAuthScopeId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "OAuth scope not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
