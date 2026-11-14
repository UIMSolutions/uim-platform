/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port: cryptographically secure random values (client secrets,
/// refresh tokens, authorization codes, salts).
module uim.platform.oauth.ports.gateways.secret_generator;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface ISecretGenerator {
  /// base64url (no padding) of `bytes` random bytes.
  string generate(size_t bytes = 32);
}
