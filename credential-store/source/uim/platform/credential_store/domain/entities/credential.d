/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.entities.credential;

// import uim.platform.credential_store.domain.types;
import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
struct Credential {
  mixin TenantEntity!CredentialId;

  NamespaceId namespaceId;
  string name;
  CredentialType type;
  string value;          // text for passwords, base64-encoded for keys/keyrings
  string metadata;       // optional, up to 10,000 chars
  string format;         // optional, up to 255 chars
  string username;       // optional, for passwords, up to 1024 chars
  CredentialStatus status;
  long version_;         // for conditional update support (ETag)

  Json toJson() const {
    return entityToJson
      .set("id", id.value)
      .set("namespaceId", namespaceId.value)
      .set("name", name)
      .set("type", type.to!string())
      .set("value", value)
      .set("metadata", metadata)
      .set("format", format)
      .set("username", username)
      .set("status", status.to!string())
      .set("version", version_);
  }
}
