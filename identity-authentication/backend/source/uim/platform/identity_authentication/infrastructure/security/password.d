/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.security.password;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Password hashing with PBKDF2-HMAC-SHA256 and a random 16 byte salt.
///
/// Format: pbkdf2-sha256$<iterations>$<salt base64url>$<hash base64url>
/// The iteration count is stored in the hash, so raising it in the
/// configuration does not invalidate existing passwords.
class Pbkdf2PasswordService : IPasswordService {
  enum prefix = "pbkdf2-sha256";
  protected uint iterations;

  this(uint iterations = 60_000) {
    this.iterations = max(iterations, 1);
  }

  string hashPassword(string plaintext) {
    auto salt = secureRandomBytes(16);
    auto hash = pbkdf2Sha256(cast(const(ubyte)[]) plaintext, salt, iterations);
    return prefix ~ "$" ~ iterations.to!string ~ "$" ~ base64Url(salt) ~ "$" ~ base64Url(hash[]);
  }

  bool verifyPassword(string plaintext, string hash) {
    auto parts = hash.split("$");
    if (parts.length != 4 || parts[0] != prefix)
      return false;
    try {
      auto rounds = parts[1].to!uint;
      if (rounds == 0 || rounds > 10_000_000)
        return false;
      auto salt = fromBase64Url(parts[2]);
      auto expected = base64Url(pbkdf2Sha256(cast(const(ubyte)[]) plaintext, salt, rounds)[]);
      return constantTimeEquals(expected, parts[3]);
    } catch (Exception) {
      return false;
    }
  }
}

///
unittest {
  mixin(ShowTest!("Pbkdf2PasswordService"));

  auto svc = new Pbkdf2PasswordService(1_000);
  auto h1 = svc.hashPassword("Secret123");
  auto h2 = svc.hashPassword("Secret123");
  assert(h1 != h2); // salted
  assert(h1.startsWith("pbkdf2-sha256$1000$"));
  assert(svc.verifyPassword("Secret123", h1));
  assert(!svc.verifyPassword("secret123", h1));
  assert(!svc.verifyPassword("Secret123", "garbage"));
  assert(!svc.verifyPassword("Secret123", "pbkdf2-sha256$x$y$z"));
  // hashes keep working after the iteration count changes
  assert(new Pbkdf2PasswordService(2_000).verifyPassword("Secret123", h1));
}
