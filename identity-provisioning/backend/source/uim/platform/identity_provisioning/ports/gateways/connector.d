/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.ports.gateways.connector;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// A technical failure of a connector (unreachable system, rejected entity).
class ConnectorException : Exception {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}

/// Driven port: talks to the external identity systems (SCIM, LDAP, Graph,
/// SuccessFactors OData, ...). Implementations throw ConnectorException.
interface IIdentityConnector {
  /// Check reachability and credentials.
  ConnectionTestResult test(const ConnectionSettings settings);
  /// All users and groups of a source system.
  SourceIdentity[] read(const ConnectionSettings source);
  /// Create or update one entity; returns its id in the target system.
  string write(const ConnectionSettings target, const PlannedOperation operation);
  /// Delete one entity from the target system.
  void remove(const ConnectionSettings target, const PlannedOperation operation);
}
