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
    string id;
    string tenantId;
    string clientId;
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
    string createdBy;
    string modifiedBy;
}

struct OAuthScopeDTO {
    string id;
    string tenantId;
    string applicationId;
    string name;
    string description;
    string createdBy;
    string modifiedBy;
}

struct AccessTokenDTO {
    string id;
    string tenantId;
    string tokenValue;
    string clientId;
    string userId;
    string scopes;
    long expiresAt;
    string createdBy;
}

struct RefreshTokenDTO {
    string id;
    string tenantId;
    string tokenValue;
    string clientId;
    string userId;
    string scopes;
    string accessTokenId;
    long expiresAt;
    string createdBy;
}

struct AuthorizationCodeDTO {
    string id;
    string tenantId;
    string code;
    string clientId;
    string userId;
    string redirectUri;
    string scopes;
    long expiresAt;
    string createdBy;
}

struct BrandingConfigDTO {
    string id;
    string tenantId;
    string name;
    string description;
    string logoUrl;
    string backgroundUrl;
    string primaryColor;
    string secondaryColor;
    string pageTitle;
    string footerText;
    string customCss;
    string createdBy;
    string modifiedBy;
}
