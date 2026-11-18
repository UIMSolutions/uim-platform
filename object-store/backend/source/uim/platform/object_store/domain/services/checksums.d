/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Content checksums and credential material.
module uim.platform.object_store.domain.services.checksums;

import std.digest : toHexString, LetterCase;
import std.digest.md : md5Of;
import std.digest.sha : sha256Of;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// S3 style ETag: MD5 of the content, lowercase hex.
string contentEtag(const(ubyte)[] data) pure nothrow {
  return toHexString!(LetterCase.lower)(md5Of(data)).idup;
}

/// Content address of a blob: SHA-256, lowercase hex.
string contentAddress(const(ubyte)[] data) pure nothrow {
  return toHexString!(LetterCase.lower)(sha256Of(data)).idup;
}

/// Hash of a secret with its salt (SHA-256, lowercase hex).
string hashSecret(string secret, string salt) pure nothrow {
  return toHexString!(LetterCase.lower)(sha256Of(cast(const(ubyte)[])(salt ~ ":" ~ secret))).idup;
}

/// Content bytes as text (UTF-8 is not validated).
string bytesToText(const(ubyte)[] data) @trusted pure nothrow {
  return cast(string) data.idup;
}

/// Compare two strings in time independent of where they differ.
bool constantTimeEquals(string a, string b) pure nothrow @nogc {
  if (a.length != b.length)
    return false;
  ubyte diff;
  foreach (i; 0 .. a.length)
    diff |= a[i] ^ b[i];
  return diff == 0;
}

/// `count` random bytes from the operating system (falls back to UUIDs).
ubyte[] randomBytes(size_t count) @trusted {
  ubyte[] buffer = new ubyte[count];
  version (Posix) {
    import std.stdio : File;

    try {
      auto f = File("/dev/urandom", "rb");
      if (f.rawRead(buffer).length == count)
        return buffer;
    } catch (Exception) {
    }
  }
  import std.uuid : randomUUID;

  size_t filled;
  while (filled < count) {
    auto u = randomUUID().data;
    auto n = min(u.length, count - filled);
    buffer[filled .. filled + n] = u[0 .. n];
    filled += n;
  }
  return buffer;
}

private enum string keyAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";

/// A new access key id: "OSAK" + 16 characters (A–Z, 2–7).
string newAccessKeyId() {
  string id = "OSAK";
  foreach (b; randomBytes(16))
    id ~= keyAlphabet[b % 32];
  return id;
}

/// A new secret access key: 40 URL safe characters.
string newSecretAccessKey() {
  import std.base64 : Base64URLNoPadding;

  return Base64URLNoPadding.encode(randomBytes(30)).idup;
}

/// A new salt: 16 random bytes, hex.
string newSalt() {
  return toHexString!(LetterCase.lower)(randomBytes(16)).idup;
}

///
unittest {
  mixin(ShowTest!("checksums"));

  auto data = cast(const(ubyte)[]) "hello";
  assert(contentEtag(data) == "5d41402abc4b2a76b9719d911017c592");
  assert(contentAddress(data) == "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824");
  assert(contentEtag([]) == "d41d8cd98f00b204e9800998ecf8427e");

  auto key = newAccessKeyId();
  assert(key.length == 20 && key.startsWith("OSAK"));
  assert(newAccessKeyId() != key);
  auto secret = newSecretAccessKey();
  assert(secret.length == 40);
  auto salt = newSalt();
  assert(salt.length == 32);
  assert(constantTimeEquals(hashSecret(secret, salt), hashSecret(secret, salt)));
  assert(!constantTimeEquals(hashSecret(secret, salt), hashSecret(secret, "other")));
}
