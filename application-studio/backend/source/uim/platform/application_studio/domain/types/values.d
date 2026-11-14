/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Value objects embedded in the aggregates (exchanged as OData complex types).
module uim.platform.application_studio.domain.types.values;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// An ordered key/value pair (environment variable, template parameter).
struct KeyValue {
  string key;
  string value;
}

/// Value of `key` in a list of pairs ("" if missing).
string valueOf(const KeyValue[] pairs, string key) {
  foreach (p; pairs)
    if (p.key == key)
      return p.value;
  return "";
}

/// One build or deployment run of a build configuration.
struct BuildRun {
  string runId; /// "<config>-<n>", e.g. "mta-build-3"
  BuildPhase phase = BuildPhase.build;
  BuildStatus status = BuildStatus.building;
  long startedAt;
  long finishedAt;
  string artifact; /// produced artifact (build) or deployment target (deploy)
  string message;
}

///
unittest {
  assert(valueOf([KeyValue("PORT", "4004")], "PORT") == "4004");
  assert(valueOf([KeyValue("PORT", "4004")], "HOST") == "");
}
