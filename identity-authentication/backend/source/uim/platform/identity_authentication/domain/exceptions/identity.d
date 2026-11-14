/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.exceptions.identity;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Base class of all identity authentication business exceptions.
class IdentityException : Exception {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}

/// A status change the business rules do not allow (e.g. activating a user
/// that is still pending verification without verifying). Mapped to HTTP 422.
class InvalidTransitionException : IdentityException {
  string entity;
  string from;
  string to;

  this(string entity, string from, string to, string file = __FILE__, size_t line = __LINE__) pure {
    super(entity ~ ": status change '" ~ from ~ "' → '" ~ to ~ "' is not allowed", file, line);
    this.entity = entity;
    this.from = from;
    this.to = to;
  }
}

/// A business rule across entities was violated. Mapped to HTTP 422.
class BusinessRuleException : IdentityException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}
