/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.mappers.application;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Application ⇄ snapshot record.
struct ApplicationMapper {
  static Json toRecord(const Application e) {
    auto r = baseRecord(e);
    r["name"] = e.name;
    r["description"] = e.description;
    r["protocol"] = enumValue(e.protocol);
    r["clientId"] = e.clientId;
    r["clientSecretHash"] = e.clientSecretHash;
    r["redirectUris"] = stringsRecord(e.redirectUris);
    r["allowedScopes"] = stringsRecord(e.allowedScopes);
    r["samlEntityId"] = e.samlEntityId;
    r["samlAcsUrl"] = e.samlAcsUrl;
    r["samlMetadataUrl"] = e.samlMetadataUrl;
    r["active"] = e.active;
    return r;
  }

  static Application fromRecord(Json r) {
    Application e;
    readBase(e, r);
    e.name = fieldString(r, "name");
    e.description = fieldString(r, "description");
    e.protocol = fieldEnum!SsoProtocol(r, "protocol", SsoProtocol.oidc);
    e.clientId = fieldString(r, "clientId");
    e.clientSecretHash = fieldString(r, "clientSecretHash");
    e.redirectUris = fieldStrings(r, "redirectUris");
    e.allowedScopes = fieldStrings(r, "allowedScopes");
    e.samlEntityId = fieldString(r, "samlEntityId");
    e.samlAcsUrl = fieldString(r, "samlAcsUrl");
    e.samlMetadataUrl = fieldString(r, "samlMetadataUrl");
    e.active = fieldBool(r, "active", true);
    return e;
  }
}
