/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Resolves the token signing secret:
///   1. configured signingSecret (OAUTH_SIGNING_SECRET or "oauth-config" service)
///   2. otherwise a random secret, generated once and kept in the document
///      store (partition "_system"), so server, CLI and GUI sharing a file
///      store sign and verify with the same key.
module uim.platform.oauth.infrastructure.security.signing_key;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct SigningKey {
  string secret;
  string source; /// "configuration" | "store" | "generated"
}

SigningKey resolveSigningKey(const OAuthConfig config, IDocumentStore store, ISecretGenerator generator) {
  if (config.signingSecret.length > 0)
    return SigningKey(config.signingSecret, "configuration");
  auto doc = store.get(Collections.keys, systemPartition, "signing");
  if (doc.type == Json.Type.object && "secret" in doc && doc["secret"].type == Json.Type.string
    && doc["secret"].get!string.length >= 32)
    return SigningKey(doc["secret"].get!string, "store");
  auto key = Json.emptyObject;
  key["id"] = "signing";
  key["algorithm"] = "HS256";
  key["secret"] = generator.generate(48);
  key["createdAt"] = nowStdTime();
  store.put(Collections.keys, systemPartition, "signing", key);
  return SigningKey(key["secret"].get!string, "generated");
}

///
unittest {
  Json[string] o;
  o["storage"] = "memory";
  auto config = loadOAuthConfig(o, "/nonexistent");
  auto store = new MemoryDocumentStore;
  auto first = resolveSigningKey(config, store, new SystemSecretGenerator);
  auto second = resolveSigningKey(config, store, new SystemSecretGenerator);
  assert(first.source == "generated" && second.source == "store" && first.secret == second.secret);
}
