/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.prompt;

import uim.platform.ai_launchpad.domain.types;

struct PromptMessage {
  PromptRole role;
  string content;
}

struct PromptParameters {
  double temperature;
  int maxTokens;
  double topP;
  double frequencyPenalty;
  double presencePenalty;
}

struct Prompt {
  PromptId id;
  PromptCollectionId collectionId;
  string name;
  string modelName;
  string modelVersion;
  PromptMessage[] messages;
  PromptParameters parameters;
  string[] inputParams;
  string lastOutput;
  PromptStatus status;
  string createdBy;
  string createdAt;
  string modifiedAt;
}
