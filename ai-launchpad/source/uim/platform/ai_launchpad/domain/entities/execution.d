/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.execution;

// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct OutputArtifact {
  string name;
  string artifactId;
  string artifactUrl;
}

struct Execution {
  ExecutionId id;
  ConnectionId connectionId;
  ConfigurationId configurationId;
  ScenarioId scenarioId;
  string resourceGroupId;
  ExecutionStatus status;
  string targetStatus;
  OutputArtifact[] outputArtifacts;
  long startedAt;
  string completedAt;
  string duration;
  string logsUrl;
  string statusMessage;
  long createdAt;
  long updatedAt;
}
