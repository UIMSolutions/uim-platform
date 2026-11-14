/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Strongly-typed identifiers. TenantId, UserId and ApplicationId come from the
/// platform base types.
module uim.platform.identity_authentication.domain.types.ids;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Identifier of a user group.
struct GroupId {
  mixin(IdTemplate);
}

/// Identifier of an authorization policy.
struct PolicyId {
  mixin(IdTemplate);
}

/// Identifier of an authenticated session.
struct SessionId {
  mixin(IdTemplate);
}

/// Identifier of an issued token.
struct TokenId {
  mixin(IdTemplate);
}

/// Identifier of a risk-based authentication rule.
struct RiskRuleId {
  mixin(IdTemplate);
}

/// Identifier of a corporate / external identity provider configuration.
struct IdpConfigId {
  mixin(IdTemplate);
}
