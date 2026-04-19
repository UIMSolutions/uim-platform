/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.types;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct OAuthClientId {
    mixin DomainId;
}

struct OAuthScopeId {
    mixin DomainId;
}

struct AccessTokenId {
    mixin DomainId;
}

struct RefreshTokenId {
    mixin DomainId;
}

struct AuthorizationCodeId {
    mixin DomainId;
}

struct BrandingConfigId {
    mixin DomainId;
}
