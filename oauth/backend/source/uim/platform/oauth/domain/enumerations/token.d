/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.enumerations.token;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// Lifecycle of access and refresh tokens. "expired" is derived from expiresAt.
enum TokenStatus : string {
  active = "active",
  expired = "expired",
  revoked = "revoked"
}

/// Why a token was revoked.
enum RevocationReason : string {
  none = "",
  manual = "manual", /// administrator or RFC 7009 revocation request
  clientBlocked = "clientBlocked",
  clientDeleted = "clientDeleted",
  secretRotated = "secretRotated",
  rotated = "rotated", /// refresh token replaced by a new one
  replayDetected = "replayDetected", /// a used code / rotated refresh token was presented again
  parentRevoked = "parentRevoked" /// the refresh token of this access token was revoked
}

/// Lifecycle of an authorization code. "expired" is derived from expiresAt.
enum AuthCodeStatus : string {
  active = "active",
  used = "used",
  expired = "expired",
  revoked = "revoked"
}
