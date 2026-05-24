/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.domain.types;
/// Unique identifier type alias for type safety.
import uim.platform.identity.authentication;

mixin(ShowModule!());

@safe:

struct GroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}


struct ApplicationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct PolicyId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SessionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TokenId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

