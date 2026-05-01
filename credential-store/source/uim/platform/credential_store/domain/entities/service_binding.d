/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.entities.service_binding;

// import uim.platform.credential_store.domain.types;
import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
struct ServiceBinding {
  mixin TenantEntity!ServiceBindingId;

  string name;
  string description;
  string clientId;           // basic auth username
  string clientSecret;       // basic auth password (hashed)
  PermissionLevel permission;
  BindingStatus status;
  NamespaceId[] allowedNamespaces; // empty = all namespaces
  long expiresAt;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("clientId", clientId)
      .set("clientSecret", clientSecret)
      .set("permission", permission.to!string)
      .set("status", status.to!string)
      .set("allowedNamespaces", allowedNamespaces.map!(ns => ns.value).array.toJson)
      .set("expiresAt", expiresAt);
  }
}