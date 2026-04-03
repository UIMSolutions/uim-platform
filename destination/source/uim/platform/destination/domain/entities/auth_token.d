/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.entities.auth_token;

import uim.platform.destination.domain.types;

/// A resolved authentication token for a destination.
struct AuthToken
{
  string type_; // "Bearer", "Basic", "SAML", etc.
  string value_; // the actual token or encoded credentials
  long expiresAt;
  TokenStatus status = TokenStatus.valid;
  string httpHeaderSuggestion; // e.g. "Authorization"
  string error;
}
