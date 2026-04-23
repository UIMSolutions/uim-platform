/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.prompt;

// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct PromptMessage {
  PromptRole role;
  string content;

  Json toJson() const {
    return Json.emptyObject
      .set("role", role)
      .set("content", content);
  }
}

struct PromptParameters {
  double temperature;
  int maxTokens;
  double topP;
  double frequencyPenalty;
  double presencePenalty;

  Json toJson() const {
    return Json.emptyObject
      .set("temperature", temperature)
      .set("max_tokens", maxTokens)
      .set("top_p", topP)
      .set("frequency_penalty", frequencyPenalty)
      .set("presence_penalty", presencePenalty);
  }
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

  Json toJson() const {
    return Json.entityToJson
      .set("collection_id", collectionId)
      .set("name", name)
      .set("model_name", modelName)
      .set("model_version", modelVersion)
      .set("messages", messages.map!(m => m.toJson)())
      .set("parameters", parameters.toJson)
      .set("input_params", inputParams)
      .set("last_output", lastOutput)
      .set("status", status);
  }
}
