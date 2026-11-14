/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.exceptions.agentry;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Base class of all Agentry business exceptions.
class AgentryException : Exception {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}

/// A lifecycle status change that the business rules do not allow
/// (e.g. deploying a withdrawn app version). Mapped to HTTP 422.
class InvalidTransitionException : AgentryException {
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

/// A business rule across entities was violated (e.g. deploying an
/// unpublished version). Mapped to HTTP 422.
class BusinessRuleException : AgentryException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}
