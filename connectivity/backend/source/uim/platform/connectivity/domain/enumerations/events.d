/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.enumerations.events;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Severity of a connectivity log entry.
enum LogSeverity {
  info,
  warning,
  error,
  critical,
}

/// What happened.
enum ConnectivityEventType {
  connectionEstablished,
  connectionLost,
  connectionRefused,
  heartbeatMissed,
  maintenanceStarted,
  authenticationSuccess,
  authenticationFailure,
  certificateExpiring,
  certificateExpired,
  certificateRevoked,
  certificateRenewed,
  channelOpened,
  channelClosed,
  channelError,
  accessDenied,
  accessGranted,
  healthCheckPassed,
  healthCheckFailed,
  destinationResolved,
  destinationNotFound,
  configurationChanged,
}

/// Kind of object an event is about.
enum SourceType {
  destination,
  cloudConnector,
  serviceChannel,
  accessRule,
  certificate,
  service,
}

/// The default severity of an event type.
LogSeverity defaultSeverity(ConnectivityEventType t) pure nothrow {
  switch (t) {
  case ConnectivityEventType.connectionLost, ConnectivityEventType.heartbeatMissed,
      ConnectivityEventType.certificateExpiring, ConnectivityEventType.maintenanceStarted,
      ConnectivityEventType.accessDenied, ConnectivityEventType.destinationNotFound:
    return LogSeverity.warning;
  case ConnectivityEventType.connectionRefused, ConnectivityEventType.authenticationFailure,
      ConnectivityEventType.channelError, ConnectivityEventType.healthCheckFailed,
      ConnectivityEventType.certificateRevoked:
    return LogSeverity.error;
  case ConnectivityEventType.certificateExpired:
    return LogSeverity.critical;
  default:
    return LogSeverity.info;
  }
}

///
unittest {
  assert(defaultSeverity(ConnectivityEventType.channelOpened) == LogSeverity.info);
  assert(defaultSeverity(ConnectivityEventType.certificateExpired) == LogSeverity.critical);
  assert(enumText(SourceType.cloudConnector) == "cloudConnector");
}
