/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Value objects embedded in the aggregates (exchanged as OData complex types).
module uim.platform.connectivity.domain.types.values;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// An ordered key/value pair (destination property, additional HTTP header).
struct KeyValue {
  string key;
  string value;
}

/// Value of `key` in a list of pairs ("" if missing). Keys are case-insensitive.
string valueOf(const KeyValue[] pairs, string key) {
  foreach (p; pairs)
    if (p.key.toLower == key.toLower)
      return p.value;
  return "";
}

/// Thresholds of the periodic health check (configured per service).
struct MonitoringPolicy {
  /// A connected Cloud Connector without heartbeat for this long is disconnected.
  int heartbeatTimeoutSeconds = 300;
  /// Certificates expiring within this many days are flagged "expiring".
  int certificateWarningDays = 30;
  /// Keep at most this many log entries per tenant (oldest are pruned, 0 = unlimited).
  int maxLogEntries = 5000;
}

/// The parts of an endpoint URL that matter for routing and access control.
struct Endpoint {
  string scheme; /// lower case, e.g. "https"
  string host; /// lower case
  int port; /// explicit or the scheme's default port
  string path = "/"; /// without query and fragment

  bool isNull() const pure nothrow {
    return host.length == 0;
  }
}

///
unittest {
  assert(valueOf([KeyValue("sap-client", "100")], "SAP-Client") == "100");
  assert(valueOf([KeyValue("a", "1")], "b") == "");
  assert(Endpoint.init.isNull);
}
