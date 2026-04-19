/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage.manage_oauth_clients;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageOAuthClientsUseCase : UIMUseCase {
    private OAuthClientRepository repo;

    this(OAuthClientRepository repo) {
        this.repo = repo;
    }

    OAuthClient getById(OAuthClientId id) {
        return repo.findById(id);
    }

    OAuthClient getByClientId(string clientId) {
        return repo.findByClientId(clientId);
    }

    OAuthClient[] list() {
        return repo.findAll();
    }

    OAuthClient[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult create(OAuthClientDTO dto) {
        OAuthClient e;
        e.id = OAuthClientId(dto.id);
        e.tenantId = TenantId(dto.tenantId);
        e.clientId = dto.clientId;
        e.clientSecret = dto.clientSecret;
        e.name = dto.name;
        e.description = dto.description;
        e.redirectUris = dto.redirectUris;
        e.allowedScopes = dto.allowedScopes;
        e.grantTypes = dto.grantTypes;
        e.accessTokenValidity = dto.accessTokenValidity;
        e.refreshTokenValidity = dto.refreshTokenValidity;
        e.contacts = dto.contacts;
        e.createdBy = dto.createdBy;
        auto error = OAuthValidator.validateOAuthClient(e);
        if (error.length > 0)
            return CommandResult(false, "", error);
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(OAuthClientDTO dto) {
        if (!repo.existsById(OAuthClientId(dto.id)))
            return CommandResult(false, "", "OAuth client not found");
        auto existing = repo.findById(OAuthClientId(dto.id));
        existing.name = dto.name;
        existing.description = dto.description;
        existing.redirectUris = dto.redirectUris;
        existing.allowedScopes = dto.allowedScopes;
        existing.grantTypes = dto.grantTypes;
        existing.accessTokenValidity = dto.accessTokenValidity;
        existing.refreshTokenValidity = dto.refreshTokenValidity;
        existing.contacts = dto.contacts;
        existing.modifiedBy = dto.modifiedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(OAuthClientId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "OAuth client not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
