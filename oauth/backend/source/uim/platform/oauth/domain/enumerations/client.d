/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.enumerations.client;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// RFC 6749 §2.1 client types.
enum ClientType : string {
  confidential = "confidential", /// can keep a secret (server side apps, services)
  public_ = "public" /// cannot keep a secret (SPA, native apps) — PKCE required
}

enum ClientStatus : string {
  active = "active",
  inactive = "inactive", /// temporarily disabled; tokens stay but are not accepted
  blocked = "blocked" /// locked; all tokens are revoked
}
