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
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct OAuthScopeId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct AccessTokenId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct RefreshTokenId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct AuthorizationCodeId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct BrandingConfigId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
