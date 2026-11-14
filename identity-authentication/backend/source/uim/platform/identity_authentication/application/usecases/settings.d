/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tunable business parameters of the authentication flows (populated from
/// the service configuration by the container).
module uim.platform.identity_authentication.application.usecases.settings;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

struct AuthenticationSettings {
  /// Token issuer (iss) and TOTP issuer label.
  string issuer = "uim-identity-authentication";
  /// SSO session lifetime.
  int sessionTimeoutMinutes = 480;
  /// Lock the account after this many consecutive failures (0 = never).
  int maxFailedLogins = 5;
  int accessTokenMinutes = 60;
  int idTokenMinutes = 60;
  int refreshTokenHours = 24;
  /// Minimum password length.
  int passwordMinLength = 8;
}
