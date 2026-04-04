/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.model;

import uim.platform.ai_launchpad.domain.types;

struct Model {
  ModelId id;
  ConnectionId connectionId;
  string name;
  string version_;
  string description;
  ScenarioId scenarioId;
  ExecutionId executionId;
  string url;
  long size;
  ModelStatus status;
  string[] labels;
  string createdAt;
  string modifiedAt;
}
