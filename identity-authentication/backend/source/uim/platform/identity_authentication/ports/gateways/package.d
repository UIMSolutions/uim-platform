/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports for security primitives and external systems
/// (password hashing, token signing, one-time passwords, OTP delivery).
module uim.platform.identity_authentication.ports.gateways;

public {
  import uim.platform.identity_authentication.ports.gateways.password;
  import uim.platform.identity_authentication.ports.gateways.secrets;
  import uim.platform.identity_authentication.ports.gateways.token;
  import uim.platform.identity_authentication.ports.gateways.mfa;
}
