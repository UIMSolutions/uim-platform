/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage.manage_access_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageAccessTokensUseCase : UIMUseCase {
    private AccessTokenRepository repo;

    this(AccessTokenRepository repo) {
        this.repo = repo;
    }

    AccessToken getById(AccessTokenId id) {
        return repo.findById(id);
    }

    AccessToken getByTokenValue(string tokenValue) {
        return repo.findByTokenValue(tokenValue);
    }

    AccessToken[] list() {
        return repo.findAll();
    }

    AccessToken[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AccessToken[] listByClientId(string clientId) {
        return repo.findByClientId(clientId);
    }

    CommandResult create(AccessTokenDTO dto) {
        AccessToken e;
        e.id = AccessTokenId(dto.id);
        e.tenantId = dto.tenantId;
        e.tokenValue = dto.tokenValue;
        e.clientId = dto.clientId;
        e.userId = dto.userId;
        e.scopes = dto.scopes;
        e.expiresAt = dto.expiresAt;
        auto error = OAuthValidator.validateAccessToken(e);
        if (error.length > 0)
            return CommandResult(false, "", error);
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult revoke(AccessTokenId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Access token not found");
        auto existing = repo.findById(id);
        existing.status = TokenStatus.revoked;
        repo.update(existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(AccessTokenId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Access token not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
