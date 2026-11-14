/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Credential handling: salted secret hashes, token fingerprints and PKCE.
///
/// Client secrets, refresh tokens and authorization codes are generated with
/// at least 256 bits of entropy (ISecretGenerator), so a single SHA-256 is
/// sufficient — a slow password hash is only needed for low entropy secrets.
module uim.platform.oauth.domain.services.credentials;

import std.base64 : Base64URLNoPadding;
import std.digest : toHexString, LetterCase;
import std.ascii : isAlphaNum;
import std.digest.sha : sha256Of;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// Hex SHA-256 of salt ~ secret.
string hashSecret(string salt, string secret) pure {
  return sha256Of(salt ~ ":" ~ secret).toHexString!(LetterCase.lower).idup;
}

/// Fingerprint of a bearer value (token, code) used as lookup key.
string fingerprint(string value) pure {
  return sha256Of(value).toHexString!(LetterCase.lower).idup;
}

/// Constant time comparison (does not leak the position of the first difference).
bool constantTimeEquals(string a, string b) pure nothrow {
  if (a.length != b.length)
    return false;
  ubyte diff;
  foreach (i; 0 .. a.length)
    diff |= cast(ubyte)(a[i] ^ b[i]);
  return diff == 0;
}

/// True if the presented secret matches the stored hash.
bool verifySecret(string salt, string storedHash, string presented) pure {
  return storedHash.length > 0 && presented.length > 0 && constantTimeEquals(hashSecret(salt, presented), storedHash);
}

/// RFC 7636 §4.1: 43-128 characters of [A-Z a-z 0-9 - . _ ~].
bool isValidCodeVerifier(string verifier) pure {
  return verifier.length >= 43 && verifier.length <= 128
    && verifier.all!(c => isAlphaNum(c) || c == '-' || c == '.' || c == '_' || c == '~');
}

/// RFC 7636 §4.2: S256 challenge of a verifier.
string s256Challenge(string verifier) pure @trusted {
  return Base64URLNoPadding.encode(sha256Of(verifier)).idup;
}

/// RFC 7636 §4.6: check the verifier against the stored challenge.
bool verifyPkce(CodeChallengeMethod method, string challenge, string verifier) pure {
  if (!isValidCodeVerifier(verifier))
    return false;
  final switch (method) {
  case CodeChallengeMethod.none:
    return false;
  case CodeChallengeMethod.plain:
    return constantTimeEquals(challenge, verifier);
  case CodeChallengeMethod.s256:
    return constantTimeEquals(challenge, s256Challenge(verifier));
  }
}

///
unittest {
  auto h = hashSecret("salt", "s3cret");
  assert(h.length == 64 && verifySecret("salt", h, "s3cret"));
  assert(!verifySecret("salt", h, "S3cret") && !verifySecret("other", h, "s3cret") && !verifySecret("salt", "", ""));
  assert(fingerprint("a") != fingerprint("b"));

  // RFC 7636 Appendix B
  enum verifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk";
  assert(s256Challenge(verifier) == "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM");
  assert(verifyPkce(CodeChallengeMethod.s256, "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM", verifier));
  assert(!verifyPkce(CodeChallengeMethod.s256, "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM", verifier ~ "x"));
  assert(verifyPkce(CodeChallengeMethod.plain, verifier, verifier));
  assert(!verifyPkce(CodeChallengeMethod.plain, "short", "short"));
}
