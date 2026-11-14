/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.security.secrets;

import std.digest.sha : sha256Of;
import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Random client secrets and SHA-256 fingerprints of high-entropy values
/// (client secrets, issued tokens). A fast hash is adequate here because the
/// inputs are random — passwords use Pbkdf2PasswordService instead.
class Sha256SecretService : ISecretService {
  string randomSecret(size_t bytes = 32) {
    return base64Url(secureRandomBytes(bytes));
  }

  string fingerprint(string value) {
    return toLowerHex(sha256Of(value)[]);
  }

  bool matches(string value, string fingerprint_) {
    return fingerprint_.length > 0 && value.length > 0 && constantTimeEquals(fingerprint(value), fingerprint_);
  }
}

///
unittest {
  mixin(ShowTest!("Sha256SecretService"));

  auto svc = new Sha256SecretService();
  auto s = svc.randomSecret();
  assert(s.length == 43);
  assert(svc.matches(s, svc.fingerprint(s)));
  assert(!svc.matches("other", svc.fingerprint(s)));
  assert(!svc.matches("", ""));
  assert(svc.fingerprint("abc") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
}
