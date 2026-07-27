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
    private IRefreshTokenRepository repo;

    this(IRefreshTokenRepository repo) {
        this.repo = repo;
    }

    RefreshToken[] listTokens(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    RefreshToken getToken(TenantId tenantId, RefreshTokenId id) {
        return repo.findById(tenantId, id);
    }

    RefreshToken getToken(TenantId tenantId, string tokenValue) {
        return repo.findByTokenValue(tenantId, tokenValue);
    }

    CommandResult createToken(RefreshTokenDTO dto) {
        RefreshToken token;
        token.id = dto.tokenId;
        token.tenantId = dto.tenantId;
        token.tokenValue = dto.tokenValue;
        // TODO: token.clientId = dto.clientId;
        token.userId = dto.userId;
        token.scopes = dto.scopes;
        token.accessTokenId = dto.accessTokenId;
        token.expiresAt = dto.expiresAt;
        auto error = OAuthValidator.validateRefreshToken(token);
        if (error.length > 0)
            return CommandResult(false, "", error);

        repo.save(token);
        return CommandResult(true, token.id.value, "");
    }

    CommandResult revokeToken(TenantId tenantId, RefreshTokenId id) {
        auto token = repo.findById(tenantId, id);
        if (token.isNull)
            return CommandResult(false, "", "Refresh token not found");

        token.status = TokenStatus.revoked;
        repo.update(token);
        return CommandResult(true, token.id.value, "");
    }

    CommandResult deleteToken(TenantId tenantId, RefreshTokenId id) {
        auto token = repo.findById(tenantId, id);
        if (token.isNull)
            return CommandResult(false, "", "Refresh token not found");

        repo.remove(token);
        return CommandResult(true, token.id.value, "");
    }
}

///
unittest {
    auto repo = new IRefreshTokenRepository();
    auto usecase = new ManageRefreshTokensUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    RefreshTokenDTO createDto;
    createDto.tenantId = tenantId;
    createDto.refreshTokenId = RefreshTokenId("refreshToken-1");
    createDto.name = "Test RefreshToken";
    auto createResult = usecase.createToken(createDto);
    assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listTokens(tenantId);
    assert(items.length == 1);

    // Test get
    auto item = usecase.getToken(tenantId, RefreshTokenId("refreshToken-1"));
    assert(!item.isNull);

    // Test delete
    auto deleteResult = usecase.deleteToken(tenantId, RefreshTokenId("refreshToken-1"));
    assert(deleteResult.success, deleteResult.message);
    assert(usecase.listTokens(tenantId).length == 0);

}
