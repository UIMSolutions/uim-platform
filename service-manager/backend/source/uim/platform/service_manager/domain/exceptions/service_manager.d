/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, CLI exit code, GUI dialog).
module uim.platform.service_manager.domain.exceptions.service_manager;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Category of a business failure.
enum ServiceManagerErrorKind {
  invalid, /// malformed or incomplete input
  notFound, /// a referenced resource does not exist
  conflict, /// uniqueness or concurrent state conflict
  ruleViolation, /// a business rule forbids the operation
  gateway /// an external system (service broker) failed
}

class ServiceManagerException : Exception {
  ServiceManagerErrorKind kind;

  this(ServiceManagerErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static ServiceManagerException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new ServiceManagerException(ServiceManagerErrorKind.invalid, msg, file, line);
  }

  static ServiceManagerException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new ServiceManagerException(ServiceManagerErrorKind.notFound, what ~ " not found", file, line);
  }

  static ServiceManagerException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new ServiceManagerException(ServiceManagerErrorKind.conflict, msg, file, line);
  }

  static ServiceManagerException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new ServiceManagerException(ServiceManagerErrorKind.ruleViolation, msg, file, line);
  }

  static ServiceManagerException gateway(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new ServiceManagerException(ServiceManagerErrorKind.gateway, msg, file, line);
  }
}

/// Kind of the failure thrown by dg, or ServiceManagerErrorKind.init with
/// `thrown == false` if dg completed (test helper).
bool failsWith(ServiceManagerErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (ServiceManagerException e)
    return e.kind == kind;
  return false;
}

///
unittest {
  assert(failsWith(ServiceManagerErrorKind.notFound, () { throw ServiceManagerException.notFound("Broker 'x'"); }));
  assert(!failsWith(ServiceManagerErrorKind.conflict, () {}));
  assert(ServiceManagerException.notFound("Broker 'x'").msg == "Broker 'x' not found");
}
