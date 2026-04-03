/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.infrastructure.security.sha256_password_service;

import uim.platform.identity.directory.domain.ports.password_service;

// import std.digest.sha;
// import std.uuid;
// import std.string : representation;

/// SHA-256 password hashing adapter (production: replace with bcrypt/argon2).
class Sha256PasswordService : PasswordService
{
  string hashPassword(string plaintext)
  {
    auto salt = randomUUID().toString()[0 .. 8];
    auto hash = sha256Of(cast(ubyte[])(plaintext ~ salt).representation);
    return salt ~ "$" ~ toHexString(hash).idup;
  }

  bool verifyPassword(string plaintext, string stored)
  {
    // import std.string : indexOf;

    auto sepIdx = stored.indexOf('$');
    if (sepIdx < 0)
      return false;

    auto salt = stored[0 .. sepIdx];
    auto expectedHash = stored[sepIdx + 1 .. $];

    auto hash = sha256Of(cast(ubyte[])(plaintext ~ salt).representation);
    return toHexString(hash).idup == expectedHash;
  }
}
