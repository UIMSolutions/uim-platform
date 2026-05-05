/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.entities.ingestion_token;

// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct IngestionToken {
  mixin TenantEntity!IngestionTokenId;

  string name;
  string tokenHash;
  TokenScope[] scopes;
  long expiresAt;
  bool isActive = true;

  Json toJson() const {
    auto scopesJson = Json.emptyArray;
    foreach (scope; scopes) {
      scopesJson ~= scope.to!string();
    }

    return entityToJson
      .set("name", name)
      .set("scopes", scopesJson)
      .set("expiresAt", expiresAt)
      .set("isActive", isActive);
  }
}
