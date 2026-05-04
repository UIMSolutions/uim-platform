/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.configuration;

// import uim.platform.ai_launchpad.domain.types;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct ParameterBinding {
  string key;
  string value;
}

struct InputArtifactBinding {
  string key;
  string artifactId;
}

struct Configuration {
  ConfigurationId id;
  ConnectionId connectionId;
  ScenarioId scenarioId;
  string executableId;
  string name;
  ParameterBinding[] parameters;
  InputArtifactBinding[] inputArtifacts;
  long createdAt;
}
