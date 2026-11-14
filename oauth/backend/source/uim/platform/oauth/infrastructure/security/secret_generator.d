/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// ISecretGenerator adapter: kernel CSPRNG (/dev/urandom). Fails closed —
/// there is deliberately no fallback to a non-cryptographic generator.
module uim.platform.oauth.infrastructure.security.secret_generator;

import std.base64 : Base64URLNoPadding;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class SystemSecretGenerator : ISecretGenerator {
  string generate(size_t bytes = 32) @trusted {
    import std.stdio : File;

    enforce(bytes >= 16 && bytes <= 1024, "Secret length must be 16-1024 bytes");
    auto buffer = new ubyte[bytes];
    auto f = File("/dev/urandom", "rb");
    scope (exit)
      f.close();
    enforce(f.rawRead(buffer).length == bytes, "Short read from /dev/urandom");
    return Base64URLNoPadding.encode(buffer).idup;
  }
}

///
unittest {
  auto g = new SystemSecretGenerator;
  auto a = g.generate(32);
  assert(a.length == 43 && a != g.generate(32));
}
