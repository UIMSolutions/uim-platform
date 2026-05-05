/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage.refresh_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageRefreshTokensUseCase { // TODO: UIMUseCase {
    private RefreshTokenRepository repo;

    this(RefreshTokenRepository repo) {
        this.repo = repo;
    }

    RefreshToken getById(RefreshTokenId id) {
        return repo.findById(id);
    }

    RefreshToken getByTokenValue(string tokenValue) {
        return repo.findByTokenValue(tokenValue);
    }

    RefreshToken[] list() {
        return repo.findAll();
    }

    RefreshToken[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult create(RefreshTokenDTO dto) {
        RefreshToken e;
        e.id = RefreshTokenId(dto.id);
        e.tenantId = dto.tenantId;
        e.tokenValue = dto.tokenValue;
        e.clientId = dto.clientId;
        e.userId = dto.userId;
        e.scopes = dto.scopes;
        e.accessTokenId = dto.accessTokenId;
        e.expiresAt = dto.expiresAt;
        auto error = OAuthValidator.validateRefreshToken(e);
        if (error.length > 0)
            return CommandResult(false, "", error);
        repo.save(e);
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult revoke(RefreshTokenId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Refresh token not found");
        auto existing = repo.findById(id);
        existing.status = TokenStatus.revoked;
        repo.update(existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(RefreshTokenId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Refresh token not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
