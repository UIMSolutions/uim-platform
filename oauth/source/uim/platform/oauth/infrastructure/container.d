/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.container;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct Container {
    ManageOAuthClientsUseCase manageOAuthClientsUseCase;
    ManageOAuthScopesUseCase manageOAuthScopesUseCase;
    ManageAccessTokensUseCase manageAccessTokensUseCase;
    ManageRefreshTokensUseCase manageRefreshTokensUseCase;
    ManageAuthorizationCodesUseCase manageAuthorizationCodesUseCase;
    ManageBrandingConfigsUseCase manageBrandingConfigsUseCase;

    OAuthClientController oauthClientController;
    OAuthScopeController oauthScopeController;
    AccessTokenController accessTokenController;
    RefreshTokenController refreshTokenController;
    AuthorizationCodeController authorizationCodeController;
    BrandingConfigController brandingConfigController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container c;

    // Repositories
    auto oauthClientRepo = new MemoryOAuthClientRepository();
    auto oauthScopeRepo = new MemoryOAuthScopeRepository();
    auto accessTokenRepo = new MemoryAccessTokenRepository();
    auto refreshTokenRepo = new MemoryRefreshTokenRepository();
    auto authorizationCodeRepo = new MemoryAuthorizationCodeRepository();
    auto brandingConfigRepo = new MemoryBrandingConfigRepository();

    // Use Cases
    c.manageOAuthClientsUseCase = new ManageOAuthClientsUseCase(oauthClientRepo);
    c.manageOAuthScopesUseCase = new ManageOAuthScopesUseCase(oauthScopeRepo);
    c.manageAccessTokensUseCase = new ManageAccessTokensUseCase(accessTokenRepo);
    c.manageRefreshTokensUseCase = new ManageRefreshTokensUseCase(refreshTokenRepo);
    c.manageAuthorizationCodesUseCase = new ManageAuthorizationCodesUseCase(authorizationCodeRepo);
    c.manageBrandingConfigsUseCase = new ManageBrandingConfigsUseCase(brandingConfigRepo);

    // Controllers
    c.oauthClientController = new OAuthClientController(c.manageOAuthClientsUseCase);
    c.oauthScopeController = new OAuthScopeController(c.manageOAuthScopesUseCase);
    c.accessTokenController = new AccessTokenController(c.manageAccessTokensUseCase);
    c.refreshTokenController = new RefreshTokenController(c.manageRefreshTokensUseCase);
    c.authorizationCodeController = new AuthorizationCodeController(c.manageAuthorizationCodesUseCase);
    c.brandingConfigController = new BrandingConfigController(c.manageBrandingConfigsUseCase);
    c.healthController = new HealthController();

    return c;
}
