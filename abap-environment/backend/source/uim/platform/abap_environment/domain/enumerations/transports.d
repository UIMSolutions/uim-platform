/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.enumerations.transports;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Kind of a transport request (CTS).
enum TransportType {
  workbench,
  customizing,
  transportOfCopies,
}

/// Status of a transport request or task.
///
///   modifiable → released → importing → imported   (error if the import fails)
enum TransportStatus {
  modifiable,
  released,
  importing,
  imported,
  error,
}
