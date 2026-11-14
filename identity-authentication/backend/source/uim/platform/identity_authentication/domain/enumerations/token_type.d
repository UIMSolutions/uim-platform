/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.enumerations.token_type;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Type of an issued security token.
enum TokenType {
  access,
  refresh,
  idToken,
  samlAssertion,
}

TokenType toTokenType(string value) {
  mixin(EnumSwitch("TokenType", "access"));
}

TokenType[] toTokenTypes(string[] values)
  => values.map!toTokenType.array;

string toString(TokenType value)
  => value.to!string;

string[] toString(TokenType[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("TokenType"));

  assert("refresh".toTokenType == TokenType.refresh);
  assert("unknown".toTokenType == TokenType.access);
  assert(TokenType.idToken.toString == "idToken");
}
