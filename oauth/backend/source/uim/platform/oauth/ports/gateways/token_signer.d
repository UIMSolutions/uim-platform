/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port: signs and verifies JWT access tokens.
module uim.platform.oauth.ports.gateways.token_signer;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface ITokenSigner {
  /// JWS algorithm ("HS256").
  string algorithm();

  /// Compact JWS of the claims.
  string sign(Json claims);

  /// Verify signature, exp and nbf; claims are set on success.
  bool verify(string token, out Json claims);
}
