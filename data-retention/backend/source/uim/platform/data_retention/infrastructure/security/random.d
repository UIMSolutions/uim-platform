/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Cryptographically secure random bytes (/dev/urandom; on other systems
/// a fallback from several random UUIDs).
module uim.platform.data_retention.infrastructure.security.random;

import std.base64 : Base64URLNoPadding;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

ubyte[] secureRandomBytes(size_t n) @trusted {
  import std.stdio : File;
  import std.uuid : randomUUID;

  try {
    auto f = File("/dev/urandom", "rb");
    auto buf = new ubyte[n];
    auto got = f.rawRead(buf);
    if (got.length == n)
      return buf;
  } catch (Exception) {
  }
  ubyte[] bytes;
  while (bytes.length < n)
    bytes ~= randomUUID().data[];
  return bytes[0 .. n];
}

/// URL safe random text (e.g. secrets, initial passwords).
string randomToken(size_t bytes = 32) @trusted {
  return Base64URLNoPadding.encode(secureRandomBytes(bytes)).idup;
}

///
unittest {
  assert(secureRandomBytes(16).length == 16 && randomToken(12).length == 16 && randomToken() != randomToken());
}
