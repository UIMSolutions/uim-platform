/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage.access_tokens;

import uim.platform.oauth;

// mixin(ShowModule!());

@safe:

class ManageAccessTokensUseCase { // TODO: UIMUseCase {
    private AccessTokenRepository repo;

    this(AccessTokenRepository repo) {
        this.repo = repo;
    }

    AccessToken getToken(TenantId tenantId, AccessTokenId id) {
        return repo.find(tenantId, id);
    }

    AccessToken getByTokenValue(TenantId tenantId, string tokenValue) {
        return repo.findByTokenValue(tenantId, tokenValue);
    }

    AccessToken[] listTokens(TenantId tenantId) {
        return repo.find(tenantId);
    }

    AccessToken[] listTokens(TenantId tenantId, string clientId) {
        return repo.findByClient(tenantId, clientId);
    }

    CommandResult createToken(AccessTokenDTO dto) {
        AccessToken token;
        token.initEntity(dto.tenantId);
        token.id = dto.tokenId;
        token.tokenValue = dto.tokenValue;
        // TODO: token.clientId = dto.clientId;
        token.userId = dto.userId;
        token.scopes = dto.scopes;
        token.expiresAt = dto.expiresAt;
        auto error = OAuthValidator.validateAccessToken(token);
        if (error.length > 0)
            return CommandResult(false, "", error);
        
        repo.save(token);
        return CommandResult(true, token.id.value, "");
    }

    CommandResult revokeToken(TenantId tenantId, AccessTokenId id) {
        auto token = repo.find(tenantId, id);
        if (token.isNull)
            return CommandResult(false, "", "Access token not found");
            
        token.status = TokenStatus.revoked;
        repo.update(token);
        return CommandResult(true, token.id.value, "");
    }

    CommandResult deleteToken(TenantId tenantId, AccessTokenId id) {
        auto token = repo.find(tenantId, id);
        if (token.isNull)            
            return CommandResult(false, "", "Access token not found");

        repo.remove(token);
        return CommandResult(true, token.id.value, "");
    }
}
