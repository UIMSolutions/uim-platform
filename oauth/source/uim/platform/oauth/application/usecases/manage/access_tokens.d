/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage.access_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageAccessTokensUseCase { // TODO: UIMUseCase {
    private IAccessTokenRepository repo;

    this(IAccessTokenRepository repo) {
        this.repo = repo;
    }

    AccessToken getToken(TenantId tenantId, AccessTokenId id) {
        return repo.findById(tenantId, id);
    }

    AccessToken getByTokenValue(TenantId tenantId, string tokenValue) {
        return repo.findByTokenValue(tenantId, tokenValue);
    }

    AccessToken[] listTokens(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AccessToken[] listTokens(TenantId tenantId, string clientId) {
        return repo.findByClient(tenantId, clientId);
    }

    CommandResult createToken(AccessTokenDTO dto) {
        auto token = AccessToken(dto.tenantId); //, UserId("test-user"));
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
        auto token = repo.findById(tenantId, id);
        if (token.isNull)
            return CommandResult(false, "", "Access token not found");
            
        token.status = TokenStatus.revoked;
        repo.update(token);
        return CommandResult(true, token.id.value, "");
    }

    CommandResult deleteToken(TenantId tenantId, AccessTokenId id) {
        auto token = repo.findById(tenantId, id);
        if (token.isNull)            
            return CommandResult(false, "", "Access token not found");

        repo.remove(token);
        return CommandResult(true, token.id.value, "");
    }
}

///
unittest {
    auto repo = new IAccessTokenRepository();
    auto usecase = new ManageAccessTokensUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    AccessTokenDTO createDto;
    createDto.tenantId = tenantId;
    createDto.accessTokenId = AccessTokenId("accessToken-1");
    createDto.name = "Test AccessToken";
    auto createResult = usecase.createToken(createDto);
    assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listTokens(tenantId);
    assert(items.length == 1);

    // Test get
    auto item = usecase.getToken(tenantId, AccessTokenId("accessToken-1"));
    assert(!item.isNull);

    // Test delete
    auto deleteResult = usecase.deleteToken(tenantId, AccessTokenId("accessToken-1"));
    assert(deleteResult.success, deleteResult.message);
    assert(usecase.listTokens(tenantId).length == 0);

}
