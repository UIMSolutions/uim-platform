/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Credentials the runtime needs. Secret material is never stored in plain
/// text: only a SHA-256 fingerprint is kept to show that one is set and to
/// detect changes.
module uim.platform.ai_core.domain.entities.secrets;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// Pull secret of a docker registry (tenant wide, id = secret name).
struct DockerRegistrySecret {
  mixin TenantEntity!DockerRegistrySecretId;

  string server;
  string username;
  string credentialFingerprint;

  bool hasCredentials() const {
    return credentialFingerprint.length > 0;
  }

  void validate() const {
    requireResourceId(id.value, "Secret name");
    requireText(server, "Registry server");
    requireText(username, "Registry user");
  }
}

/// Object store secret of a resource group (id = secret name, referenced
/// by artifact URLs ai://<name>/<path>).
struct ObjectStoreSecret {
  mixin TenantEntity!ObjectStoreSecretId;

  ResourceGroupId resourceGroupId;
  ObjectStoreType type = ObjectStoreType.s3;
  string bucket;
  string endpoint;
  string region;
  string pathPrefix;
  string credentialFingerprint;

  bool hasCredentials() const {
    return credentialFingerprint.length > 0;
  }

  void validate() const {
    requireResourceId(id.value, "Secret name");
    requireText(bucket, "Bucket");
  }
}

/// SHA-256 fingerprint (first 16 hex chars) of secret material, "" for "".
string fingerprintOf(string secret) @trusted {
  import std.digest.sha : sha256Of;
  import std.digest : toHexString, LetterCase;

  if (secret.length == 0)
    return "";
  auto digest = sha256Of(secret);
  return toHexString!(LetterCase.lower)(digest)[0 .. 16].idup;
}

///
unittest {
  assert(fingerprintOf("") == "" && fingerprintOf("x").length == 16 && fingerprintOf("x") != fingerprintOf("y"));
}
