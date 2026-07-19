/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.dto;

import uim.platform.oauth;
mixin(ShowModule!());

@safe:

struct OAuthClientDTO {
    OAuthClientId clientId;
    TenantId tenantId;
    OAuthClientId parentClientId;

    string clientSecret;
    string name;
    string description;
    string clientType;
    string redirectUris;
    string allowedScopes;
    string grantTypes;
    long accessTokenValidity;
    long refreshTokenValidity;
    string contacts;
    UserId createdBy;
    UserId updatedBy;
}

struct OAuthScopeDTO {
    OAuthScopeId scopeId;
    TenantId tenantId;
    string applicationId;
    string name;
    string description;
    UserId createdBy;
    UserId updatedBy;
}

struct AccessTokenDTO {
    AccessTokenId tokenId;
    TenantId tenantId;
    OAuthClientId clientId;

    string tokenValue;
    UserId userId;
    string scopes;
    long expiresAt;
    UserId createdBy;
}

struct RefreshTokenDTO {
    RefreshTokenId tokenId;
    TenantId tenantId;
    OAuthClientId clientId;

    string tokenValue;
    UserId userId;
    string scopes;
    string accessTokenId;
    long expiresAt;
    UserId createdBy;
}

struct AuthorizationCodeDTO {
    AuthorizationCodeId codeId;
    TenantId tenantId;

    string code;
    OAuthClientId clientId;
    UserId userId;
    string redirectUri;
    string scopes;
    long expiresAt;
    UserId createdBy;
}

struct BrandingConfigDTO {
    BrandingConfigId configId;
    TenantId tenantId;

    string name;
    string description;
    string logoUrl;
    string backgroundUrl;
    string primaryColor;
    string secondaryColor;
    string pageTitle;
    string footerText;
    string customCss;
    UserId createdBy;
    UserId updatedBy;
}
