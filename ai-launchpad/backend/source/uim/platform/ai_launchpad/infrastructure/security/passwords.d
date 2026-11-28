/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Password hashing adapter: PBKDF2-HMAC-SHA256 with a 16 byte random salt.
/// Stored form: "pbkdf2-sha256$<iterations>$<salt b64url>$<hash b64url>".
module uim.platform.ai_launchpad.infrastructure.security.passwords;

import std.base64 : Base64URLNoPadding;
import std.digest.hmac : HMAC;
import std.digest.sha : SHA256;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

enum string pbkdf2Prefix = "pbkdf2-sha256";

/// PBKDF2 (RFC 8018) with HMAC-SHA256, one 32 byte block.
ubyte[32] pbkdf2Sha256(const(ubyte)[] password, const(ubyte)[] salt, uint iterations) @trusted {
  auto mac = HMAC!SHA256(password);
  mac.put(salt);
  mac.put(cast(const(ubyte)[])[0, 0, 0, 1]);
  ubyte[32] u = mac.finish();
  ubyte[32] t = u;
  foreach (_; 1 .. iterations) {
    mac.start();
    mac.put(u[]);
    u = mac.finish();
    t[] ^= u[];
  }
  return t;
}

class Pbkdf2PasswordHasher : IPasswordHasher {
  uint iterations;

  this(uint iterations = 120_000) {
    enforce(iterations >= 1000, "passwordIterations must be at least 1000");
    this.iterations = iterations;
  }

  string hash(string password) @trusted {
    auto salt = secureRandomBytes(16);
    auto h = pbkdf2Sha256(cast(const(ubyte)[]) password, salt, iterations);
    return format("%s$%d$%s$%s", pbkdf2Prefix, iterations, Base64URLNoPadding.encode(salt), Base64URLNoPadding.encode(h[]));
  }

  bool verify(string password, string encoded) @trusted {
    auto parts = encoded.split("$");
    if (parts.length != 4 || parts[0] != pbkdf2Prefix)
      return false;
    try {
      auto rounds = parts[1].to!uint;
      if (rounds < 1000 || rounds > 10_000_000)
        return false;
      auto salt = Base64URLNoPadding.decode(parts[2]);
      auto expected = Base64URLNoPadding.decode(parts[3]);
      auto actual = pbkdf2Sha256(cast(const(ubyte)[]) password, salt, rounds);
      if (expected.length != actual.length)
        return false;
      ubyte diff;
      foreach (i; 0 .. actual.length)
        diff |= actual[i] ^ expected[i];
      return diff == 0;
    } catch (Exception)
      return false;
  }

  bool needsRehash(string encoded) {
    auto parts = encoded.split("$");
    try
      return parts.length != 4 || parts[0] != pbkdf2Prefix || parts[1].to!uint < iterations;
    catch (Exception)
      return true;
  }
}

///
unittest {
  import std.digest : toHexString, LetterCase;

  // RFC 7914 / common PBKDF2-HMAC-SHA256 test vector (c = 1, dkLen = 32)
  auto v = pbkdf2Sha256(cast(const(ubyte)[]) "password", cast(const(ubyte)[]) "salt", 1);
  assert(toHexString!(LetterCase.lower)(v) == "120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b");
  auto v2 = pbkdf2Sha256(cast(const(ubyte)[]) "password", cast(const(ubyte)[]) "salt", 2);
  assert(toHexString!(LetterCase.lower)(v2) == "ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43");

  auto hasher = new Pbkdf2PasswordHasher(1000);
  auto h = hasher.hash("correct horse");
  assert(h.startsWith("pbkdf2-sha256$1000$") && h != hasher.hash("correct horse"));
  assert(hasher.verify("correct horse", h) && !hasher.verify("wrong", h) && !hasher.verify("x", "garbage"));
  assert(!hasher.needsRehash(h) && new Pbkdf2PasswordHasher(2000).needsRehash(h));
}
