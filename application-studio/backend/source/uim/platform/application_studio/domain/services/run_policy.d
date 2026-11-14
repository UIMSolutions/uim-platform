/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Rules of run configurations: ports, debug mode and environment.
module uim.platform.application_studio.domain.services.run_policy;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Validate the launch settings of a run configuration.
void validateLaunch(const ref RunConfiguration rc) {
  validate(rc.entryPoint.strip.length > 0, "Entry point is required (e.g. 'npm start')");
  validatePort("Port", rc.port);
  if (rc.mode == RunMode.debug_)
    validate(rc.debugPort != 0, "Debug mode needs a debug port");
  if (rc.debugPort != 0) {
    validatePort("Debug port", rc.debugPort);
    validate(rc.debugPort != rc.port, "Port and debug port must differ");
  }
  string[] keys;
  foreach (kv; rc.environment) {
    validate(isEnvName(kv.key), "Invalid environment variable name '" ~ kv.key ~ "'");
    validate(!keys.canFind(kv.key), "Environment variable '" ~ kv.key ~ "' is defined twice");
    keys ~= kv.key;
  }
}

/// Ports used by the live runs of a dev space (excluding `self`).
int[] portsInUse(const RunConfiguration[] runs, RunConfigurationId self) {
  int[] ports;
  foreach (r; runs) {
    if (r.id == self || !r.status.isLive)
      continue;
    ports ~= r.port;
    if (r.debugPort != 0)
      ports ~= r.debugPort;
  }
  return ports;
}

/// A run may start only if its ports are free in the dev space.
void ensurePortsFree(const RunConfiguration rc, const int[] used) {
  ensureState(!used.canFind(rc.port), "Port " ~ rc.port.to!string ~ " is already used by another running configuration");
  ensureState(rc.debugPort == 0 || !used.canFind(rc.debugPort),
    "Debug port " ~ rc.debugPort.to!string ~ " is already used by another running configuration");
}

///
unittest {
  bool failed(void delegate() @safe f) {
    try
      f();
    catch (StudioException)
      return true;
    return false;
  }

  RunConfiguration rc;
  rc.entryPoint = "npm start";
  rc.port = 4004;
  validateLaunch(rc);
  rc.mode = RunMode.debug_;
  assert(failed(() => validateLaunch(rc)));
  rc.debugPort = 4004;
  assert(failed(() => validateLaunch(rc)));
  rc.debugPort = 9229;
  rc.environment = [KeyValue("NODE_ENV", "development"), KeyValue("NODE_ENV", "x")];
  assert(failed(() => validateLaunch(rc)));

  RunConfiguration other;
  other.id = RunConfigurationId("o");
  other.status = RunStatus.running;
  other.port = 4004;
  assert(portsInUse([other], RunConfigurationId("x")) == [4004]);
  assert(failed(() => ensurePortsFree(rc, [4004])));
  ensurePortsFree(rc, [8080]);
}
