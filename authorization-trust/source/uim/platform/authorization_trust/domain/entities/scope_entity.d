/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.entities.scope_entity;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:
/// A fine-grained authorization scope.
/// Scopes are referenced by roles and requested by OAuth 2.0 clients.
struct ScopeEntity {
  mixin IdEntity!ScopeId;
  string  name;         // unique scope name, e.g. "app.Read"
  string  description;
  string  appId;        // owning application
  
  Json toJson() const {
    return entityToJson
      .set("id", id)
      .set("name", name)
      .set("description", description)
      .set("appId", appId);
  }
}
