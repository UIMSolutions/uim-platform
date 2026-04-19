/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.services.oauth_validator;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct OAuthValidator {
    static string validateOAuthClient(OAuthClient entity) {
        if (entity.name.length == 0) return "Client name is required";
        if (entity.tenantId.value.length == 0) return "Tenant ID is required";
        if (entity.clientId.length == 0) return "Client ID is required";
        if (entity.clientSecret.length == 0) return "Client secret is required";
        return "";
    }

    static string validateOAuthScope(OAuthScope entity) {
        if (entity.name.length == 0) return "Scope name is required";
        if (entity.tenantId.value.length == 0) return "Tenant ID is required";
        if (entity.applicationId.length == 0) return "Application ID is required";
        return "";
    }

    static string validateAccessToken(AccessToken entity) {
        if (entity.tokenValue.length == 0) return "Token value is required";
        if (entity.clientId.length == 0) return "Client ID is required";
        if (entity.tenantId.value.length == 0) return "Tenant ID is required";
        return "";
    }

    static string validateRefreshToken(RefreshToken entity) {
        if (entity.tokenValue.length == 0) return "Token value is required";
        if (entity.clientId.length == 0) return "Client ID is required";
        if (entity.tenantId.value.length == 0) return "Tenant ID is required";
        return "";
    }

    static string validateAuthorizationCode(AuthorizationCode entity) {
        if (entity.code.length == 0) return "Authorization code is required";
        if (entity.clientId.length == 0) return "Client ID is required";
        if (entity.redirectUri.length == 0) return "Redirect URI is required";
        if (entity.tenantId.value.length == 0) return "Tenant ID is required";
        return "";
    }

    static string validateBrandingConfig(BrandingConfig entity) {
        if (entity.name.length == 0) return "Branding config name is required";
        if (entity.tenantId.value.length == 0) return "Tenant ID is required";
        return "";
    }
}
