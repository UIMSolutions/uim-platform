/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.enumerations.grant;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// Supported grant types (wire names). The implicit and resource owner
/// password grants are deliberately not offered (OAuth 2.0 Security BCP / OAuth 2.1).
enum GrantType : string {
  authorizationCode = "authorization_code",
  clientCredentials = "client_credentials",
  refreshToken = "refresh_token"
}

/// PKCE code challenge method (RFC 7636).
enum CodeChallengeMethod : string {
  none = "",
  plain = "plain",
  s256 = "S256"
}
