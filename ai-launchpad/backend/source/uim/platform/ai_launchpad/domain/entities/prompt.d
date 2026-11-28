/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A prompt template of the generative AI hub: a system and a user message
/// with {{placeholders}}, the model and its sampling parameters. Changing
/// the messages or the model creates a new version. Archived prompts cannot
/// be run.
module uim.platform.ai_launchpad.domain.entities.prompt;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Prompt {
  mixin TenantEntity!PromptId;

  PromptCollectionId collectionId;
  string name;
  string description;
  string modelName = "gpt-4o-mini";
  string modelVersion = "latest";
  string systemMessage;
  string userMessage;
  double temperature = 0.7;
  int maxTokens = 256;
  double topP = 1.0;
  PromptStatus status = PromptStatus.draft;
  int version_ = 1;
  string lastOutput;
  long lastRunAt;
  int runCount;

  /// The placeholders of both messages, in order of appearance.
  string[] inputParams() const {
    auto result = placeholders(systemMessage);
    foreach (p; placeholders(userMessage))
      if (!result.canFind(p))
        result ~= p;
    return result;
  }

  void requireRunnable() const {
    if (status == PromptStatus.archived)
      throw AilpException.ruleViolation("Prompt '" ~ id.value ~ "' is archived and cannot be run");
  }

  void validate() const {
    requireId(id.value, "Prompt ID");
    requireId(collectionId.value, "Prompt collection");
    requireText(name, "Prompt name");
    requireMaxLength(name, 200, "Prompt name");
    requireMaxLength(description, 2000, "Description");
    requireId(modelName, "Model name");
    requireMaxLength(modelVersion, 64, "Model version");
    requireText(userMessage, "User message");
    requireMaxLength(systemMessage, 32_000, "System message");
    requireMaxLength(userMessage, 32_000, "User message");
    requireRangeF(temperature, 0, 2, "Temperature");
    requireRange(maxTokens, 1, 32_768, "Max tokens");
    requireRangeF(topP, 0, 1, "Top P");
    requirePlaceholders(systemMessage);
    requirePlaceholders(userMessage);
  }
}

///
unittest {
  Prompt p;
  p.id = PromptId("summarize");
  p.collectionId = PromptCollectionId("c");
  p.name = "Summarize";
  p.systemMessage = "You answer in {{language}}.";
  p.userMessage = "Summarize for {{audience}} in {{language}}: {{text}}";
  p.validate();
  assert(p.inputParams == ["language", "audience", "text"], p.inputParams.to!string);
  p.temperature = 3;
  assert(failsWith(AilpErrorKind.invalid, () { p.validate(); }));
  p.temperature = 0.2;
  p.status = PromptStatus.archived;
  assert(failsWith(AilpErrorKind.ruleViolation, () { p.requireRunnable(); }));
}
