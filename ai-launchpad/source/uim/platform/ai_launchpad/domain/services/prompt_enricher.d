/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.services.prompt_enricher;

import uim.platform.ai_launchpad.domain.entities.prompt;
import uim.platform.ai_launchpad.domain.types;

class PromptEnricher {
  /// Apply default parameters if not set
  void applyDefaults(Prompt p) {
    if (p.parameters.maxTokens == 0) p.parameters.maxTokens = 256;
    if (p.parameters.temperature == 0.0) p.parameters.temperature = 0.7;
    if (p.parameters.topP == 0.0) p.parameters.topP = 1.0;
  }

  /// Validate prompt message structure
  bool validateMessages(Prompt p) {
    if (p.messages.length == 0) return false;
    // Must have at least one user message
    foreach (m; p.messages) {
      if (m.role == PromptRole.user && m.content.length > 0) return true;
    }
    return false;
  }

  /// Substitute input parameters in prompt messages
  string substituteParams(string template_, string[] paramNames, string[] paramValues) {
    string result = template_;
    foreach (i, name; paramNames) {
      if (i < paramValues.length) {
        import std.array : replace;
        result = result.replace("{{" ~ name ~ "}}", paramValues[i]);
      }
    }
    return result;
  }
}
