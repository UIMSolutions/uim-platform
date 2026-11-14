/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// ITokenSigner adapter: HS256 JWS via uim-platform:service. Platform
/// services configured with jwtSecret = this signing secret accept the
/// issued tokens directly.
module uim.platform.oauth.infrastructure.security.token_signer;

import uim.platform.service.infrastructure.security.context : Hs256TokenVerifier;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class Hs256TokenSigner : ITokenSigner {
  protected Hs256TokenVerifier jws;

  this(string secret) {
    enforce(secret.length >= 32, "The token signing secret must have at least 32 characters");
    jws = new Hs256TokenVerifier(secret, 0);
  }

  string algorithm() {
    return "HS256";
  }

  string sign(Json claims) {
    return jws.sign(claims);
  }

  bool verify(string token, out Json claims) {
    return jws.verify(token, claims);
  }
}

///
unittest {
  auto signer = new Hs256TokenSigner("0123456789abcdef0123456789abcdef");
  auto token = signer.sign(parseJsonString(`{"zid":"t1","client_id":"c"}`));
  Json claims;
  assert(signer.verify(token, claims) && claims["zid"].get!string == "t1");
  assert(!signer.verify(token ~ "x", claims));
  assert(!new Hs256TokenSigner("fedcba9876543210fedcba9876543210").verify(token, claims));
}
