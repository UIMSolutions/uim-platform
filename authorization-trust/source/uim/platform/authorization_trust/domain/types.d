/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.types;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// ID type aliases
// ---------------------------------------------------------------------------
struct OAuthClientId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct ScopeId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct RoleId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct RoleCollectionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct UserAssignmentId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct IdentityProviderId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
