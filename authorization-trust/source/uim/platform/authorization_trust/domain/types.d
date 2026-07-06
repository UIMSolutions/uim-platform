/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.types;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// ID type aliases
// ---------------------------------------------------------------------------
struct OAuthClientId {
    mixin(IdTemplate);
}
struct ScopeId {
    mixin(IdTemplate);
}
struct RoleId {
    mixin(IdTemplate);
}
struct RoleCollectionId {
    mixin(IdTemplate);
}
struct UserAssignmentId {
    mixin(IdTemplate);
}
struct IdentityProviderId {
    mixin(IdTemplate);
}
