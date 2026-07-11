/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.types;
/// Unique identifier type alias for type safety.
import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

struct GroupId {
  mixin(IdTemplate);
}


struct PolicyId {
  mixin(IdTemplate);
}

struct SessionId {
  mixin(IdTemplate);
}

struct TokenId {
  mixin(IdTemplate);
}

struct RiskRuleId {
  mixin(IdTemplate);
}

struct IdpConfigId {
  mixin(IdTemplate);
}
