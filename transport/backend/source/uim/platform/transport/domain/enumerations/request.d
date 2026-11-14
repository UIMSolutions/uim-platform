/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.enumerations.request;

@safe:

/// Kind of content carried by a transport request.
enum ContentType {
  mtaArchive,
  integrationContent,
  htmlApp,
  abapCorContent,
  other
}

/// Aggregated lifecycle status of a transport request (derived from its queue entries).
enum RequestStatus {
  initial,
  running,
  success,
  failed,
  warning,
  outdated,
  repeating
}
