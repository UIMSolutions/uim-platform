/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the built-in login: password hashing and token issuing
/// (adapters in infrastructure/security).
module uim.platform.job_scheduling.ports.gateways.credentials;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

interface IPasswordHasher {
  /// Salted, slow hash in a self-describing text form.
  string hash(string password);
  /// Constant time comparison with a stored hash.
  bool verify(string password, string encoded);
  /// True if the stored hash uses weaker parameters than the current ones.
  bool needsRehash(string encoded);
}

struct IssuedToken {
  string accessToken;
  string tokenType = "Bearer";
  long expiresIn; /// seconds
  long expiresAt; /// unix time
}

interface ITokenIssuer {
  /// A signed access token for the user with the given scopes.
  IssuedToken issue(TenantId t, const UserAccount user, const string[] scopes);
}
