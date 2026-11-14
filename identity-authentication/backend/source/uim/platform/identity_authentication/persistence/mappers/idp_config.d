/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.mappers.idp_config;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// IdpConfig ⇄ snapshot record.
struct IdpConfigMapper {
  static Json toRecord(const IdpConfig e) {
    auto r = baseRecord(e);
    r["name"] = e.name;
    r["idpType"] = enumValue(e.idpType);
    r["metadataUrl"] = e.metadataUrl;
    r["authorizationEndpoint"] = e.authorizationEndpoint;
    r["tokenEndpoint"] = e.tokenEndpoint;
    r["userInfoEndpoint"] = e.userInfoEndpoint;
    r["clientId"] = e.clientId;
    r["clientSecret"] = e.clientSecret;
    r["domainHints"] = stringsRecord(e.domainHints);
    r["isDefault"] = e.isDefault;
    r["active"] = e.active;
    return r;
  }

  static IdpConfig fromRecord(Json r) {
    IdpConfig e;
    readBase(e, r);
    e.name = fieldString(r, "name");
    e.idpType = fieldEnum!IdpType(r, "idpType", IdpType.oidc);
    e.metadataUrl = fieldString(r, "metadataUrl");
    e.authorizationEndpoint = fieldString(r, "authorizationEndpoint");
    e.tokenEndpoint = fieldString(r, "tokenEndpoint");
    e.userInfoEndpoint = fieldString(r, "userInfoEndpoint");
    e.clientId = fieldString(r, "clientId");
    e.clientSecret = fieldString(r, "clientSecret");
    e.domainHints = fieldStrings(r, "domainHints");
    e.isDefault = fieldBool(r, "isDefault");
    e.active = fieldBool(r, "active", true);
    return e;
  }
}
