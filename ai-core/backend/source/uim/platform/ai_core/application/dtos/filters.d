/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Query filters of the list operations (empty fields match everything).
module uim.platform.ai_core.application.dtos.filters;

import std.uni : icmp;
import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct ConfigurationFilter {
  ScenarioId scenarioId;
  ExecutableId executableId;

  bool matches(const Configuration c) const {
    return (scenarioId.isNull || c.scenarioId == scenarioId) && (executableId.isNull || c.executableId == executableId);
  }
}

struct ArtifactFilter {
  ScenarioId scenarioId;
  ExecutionId executionId;
  string kind;
  string name;

  bool matches(const Artifact a) const {
    return (scenarioId.isNull || a.scenarioId == scenarioId) && (executionId.isNull || a.executionId == executionId)
      && (kind.length == 0 || icmp(kind, cast(string) a.kind) == 0) && (name.length == 0 || a.name == name);
  }
}

/// Filter of executions and deployments.
struct RunFilter {
  ScenarioId scenarioId;
  ExecutableId executableId;
  ConfigurationId configurationId;
  string status;

  bool matches(E)(const E e) const {
    return (scenarioId.isNull || e.scenarioId == scenarioId) && (executableId.isNull || e.executableId == executableId)
      && (configurationId.isNull || e.configurationId == configurationId)
      && (status.length == 0 || icmp(status, cast(string) e.status) == 0);
  }
}
