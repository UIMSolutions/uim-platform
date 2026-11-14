/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.enumerations.idp_type;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Identity provider type for delegated authentication.
enum IdpType {
  local,
  saml,
  oidc,
  ldap,
  corporate,
}

IdpType toIdpType(string value) {
  mixin(EnumSwitch("IdpType", "local"));
}

IdpType[] toIdpTypes(string[] values)
  => values.map!toIdpType.array;

string toString(IdpType value)
  => value.to!string;

string[] toString(IdpType[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("IdpType"));

  assert("oidc".toIdpType == IdpType.oidc);
  assert("unknown".toIdpType == IdpType.local);
  assert(IdpType.corporate.toString == "corporate");
}
