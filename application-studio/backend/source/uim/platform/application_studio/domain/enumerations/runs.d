/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.enumerations.runs;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// How a run configuration launches the project.
enum RunMode {
  run,
  debug_, /// "debug": needs a debug port
  test,
  preview,
}

/// Status of a run configuration.
///
///   idle | stopped | error → starting → running | error ;  running → stopped
enum RunStatus {
  idle,
  starting,
  running,
  stopped,
  error,
}

/// True while the run occupies its port.
bool isLive(RunStatus s) pure nothrow {
  return s == RunStatus.starting || s == RunStatus.running;
}

///
unittest {
  assert(enumText(RunMode.debug_) == "debug");
  assert(RunStatus.starting.isLive && !RunStatus.stopped.isLive);
}
