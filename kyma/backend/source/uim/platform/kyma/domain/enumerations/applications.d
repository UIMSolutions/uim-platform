/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.enumerations.applications;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Connectivity of an external application (Application Connector).
enum AppConnectivityStatus {
  disconnected,
  pairing,
  connected,
  error,
}

/// What an external application registers.
enum AppRegistrationType {
  api,
  events,
  apiAndEvents,
}
