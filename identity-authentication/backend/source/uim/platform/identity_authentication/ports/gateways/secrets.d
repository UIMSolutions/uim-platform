/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.gateways.secrets;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driven port: high-entropy secrets (client secrets, token fingerprints).
interface ISecretService {
  /// A new random secret (URL-safe text).
  string randomSecret(size_t bytes = 32);
  /// Fast one-way fingerprint (hex SHA-256) of a high-entropy value.
  string fingerprint(string value);
  /// Constant-time check of a value against its fingerprint.
  bool matches(string value, string fingerprint);
}
