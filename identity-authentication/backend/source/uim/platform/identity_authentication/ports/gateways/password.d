/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.gateways.password;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driven port: password hashing (slow, salted KDF).
interface IPasswordService {
  string hashPassword(string plaintext);
  bool verifyPassword(string plaintext, string hash);
}
