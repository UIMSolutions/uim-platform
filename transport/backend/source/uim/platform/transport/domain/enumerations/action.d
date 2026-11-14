/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.enumerations.action;

@safe:

/// Kind of operation recorded in the transport audit trail.
enum ActionType {
  export_,
  import_,
  forward,
  reset,
  delete_,
  schedule
}

/// Status of a recorded transport action.
enum ActionStatus {
  initial,
  running,
  success,
  failed,
  warning
}
