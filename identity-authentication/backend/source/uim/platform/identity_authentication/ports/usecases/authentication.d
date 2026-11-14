/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.usecases.authentication;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driving port: form login with risk-based MFA, logout.
interface IAuthenticationUseCase {
  AuthResult login(AuthRequest request);
  /// Revoke the session and every token issued for it.
  UsecaseResult logout(TenantId tenantId, SessionId sessionId);
}
