/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed identifiers. TenantId and UserId come from uim-framework.
module uim.platform.oauth.domain.types.ids;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct OAuthClientId { mixin(IdTemplate); }
struct OAuthScopeId { mixin(IdTemplate); }
struct AccessTokenId { mixin(IdTemplate); }
struct RefreshTokenId { mixin(IdTemplate); }
struct AuthorizationCodeId { mixin(IdTemplate); }
struct BrandingConfigId { mixin(IdTemplate); }

/// A new random identifier (UUID v4) for resource keys. Not a secret —
/// credentials come from the ISecretGenerator port.
string newResourceId() @trusted {
  import std.uuid : randomUUID;

  return randomUUID().toString;
}

///
unittest {
  assert(newResourceId().length == 36);
  assert(newResourceId() != newResourceId());
  assert(OAuthClientId("c").value == "c" && OAuthClientId.init.isNull);
}
