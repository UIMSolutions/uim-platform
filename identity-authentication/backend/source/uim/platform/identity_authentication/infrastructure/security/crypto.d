/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Cryptographic building blocks: secure random bytes, constant-time
/// comparison, base32 / base64url, HMAC and PBKDF2.
module uim.platform.identity_authentication.infrastructure.security.crypto;

import std.base64 : Base64URLNoPadding;
import std.digest.hmac : HMAC;
import std.digest.sha : SHA1, SHA256;
import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// n bytes from the operating system CSPRNG (/dev/urandom).
ubyte[] secureRandomBytes(size_t n) @trusted {
  import std.stdio : File;

  auto buffer = new ubyte[n];
  try {
    auto f = File("/dev/urandom", "rb");
    auto got = f.rawRead(buffer);
    if (got.length == n)
      return buffer;
  } catch (Exception) {
  }
  // Fallback for platforms without /dev/urandom — not a CSPRNG.
  import std.random : Random, unpredictableSeed, uniform;

  logWarn("identity-authentication: /dev/urandom unavailable, falling back to a PRNG");
  auto rng = Random(unpredictableSeed);
  foreach (ref b; buffer)
    b = cast(ubyte) uniform(0, 256, rng);
  return buffer;
}

/// Compare without early exit (timing-safe for equal-length secrets).
bool constantTimeEquals(scope const(char)[] a, scope const(char)[] b) pure nothrow @nogc {
  if (a.length != b.length)
    return false;
  ubyte diff;
  foreach (i; 0 .. a.length)
    diff |= a[i] ^ b[i];
  return diff == 0;
}

string base64Url(const(ubyte)[] data) pure {
  return Base64URLNoPadding.encode(data).idup;
}

ubyte[] fromBase64Url(string text) pure {
  return Base64URLNoPadding.decode(text.stripRight("="));
}

private enum base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";

/// RFC 4648 base32 without padding (TOTP secrets).
string base32Encode(const(ubyte)[] data) pure {
  string result;
  uint buffer;
  int bits;
  foreach (b; data) {
    buffer = (buffer << 8) | b;
    bits += 8;
    while (bits >= 5) {
      result ~= base32Alphabet[(buffer >> (bits - 5)) & 31];
      bits -= 5;
    }
  }
  if (bits > 0)
    result ~= base32Alphabet[(buffer << (5 - bits)) & 31];
  return result;
}

/// Decode base32 (case-insensitive, ignores padding and spaces). Throws on junk.
ubyte[] base32Decode(string text) pure {
  ubyte[] result;
  uint buffer;
  int bits;
  foreach (c; text) {
    if (c == '=' || c == ' ' || c == '-')
      continue;
    auto upper = (c >= 'a' && c <= 'z') ? cast(char)(c - 32) : c;
    auto value = base32Alphabet.indexOf(upper);
    if (value < 0)
      throw new Exception("invalid base32 character '" ~ c ~ "'");
    buffer = (buffer << 5) | cast(uint) value;
    bits += 5;
    if (bits >= 8) {
      result ~= cast(ubyte)((buffer >> (bits - 8)) & 0xFF);
      bits -= 8;
    }
  }
  return result;
}

ubyte[32] hmacSha256(const(ubyte)[] key, const(ubyte)[] data) {
  auto mac = HMAC!SHA256(key);
  mac.put(data);
  return mac.finish();
}

ubyte[20] hmacSha1(const(ubyte)[] key, const(ubyte)[] data) {
  auto mac = HMAC!SHA1(key);
  mac.put(data);
  return mac.finish();
}

/// PBKDF2-HMAC-SHA256 (RFC 8018) with a 32 byte derived key.
ubyte[32] pbkdf2Sha256(const(ubyte)[] password, const(ubyte)[] salt, uint iterations) {
  // keyed HMAC state, copied per iteration (saves re-hashing the key pads)
  const prototype = HMAC!SHA256(password);

  auto first = cast() prototype;
  first.put(salt);
  first.put(cast(const(ubyte)[])[0, 0, 0, 1]); // INT(1): single block
  ubyte[32] u = first.finish();
  ubyte[32] t = u;
  foreach (_; 1 .. iterations) {
    auto mac = cast() prototype;
    mac.put(u[]);
    u = mac.finish();
    t[] ^= u[];
  }
  return t;
}

string toLowerHex(const(ubyte)[] data) pure {
  enum digits = "0123456789abcdef";
  auto result = new char[data.length * 2];
  foreach (i, b; data) {
    result[2 * i] = digits[b >> 4];
    result[2 * i + 1] = digits[b & 15];
  }
  return result.idup;
}

///
unittest {
  mixin(ShowTest!("crypto"));

  // RFC 7914 §11 / well-known PBKDF2-HMAC-SHA256 vectors
  auto p = cast(const(ubyte)[]) "password";
  auto s = cast(const(ubyte)[]) "salt";
  assert(toLowerHex(pbkdf2Sha256(p, s, 1)) == "120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b");
  assert(toLowerHex(pbkdf2Sha256(p, s, 2)) == "ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43");

  // RFC 4648 base32
  assert(base32Encode(cast(const(ubyte)[]) "foobar") == "MZXW6YTBOI");
  assert(base32Decode("mzxw6ytboi") == cast(const(ubyte)[]) "foobar");
  assert(base64Url(cast(const(ubyte)[]) "\xff\xfe") == "__4");

  assert(constantTimeEquals("abc", "abc") && !constantTimeEquals("abc", "abd") && !constantTimeEquals("a", "ab"));
  assert(secureRandomBytes(16).length == 16);
  assert(secureRandomBytes(16) != secureRandomBytes(16));
}
