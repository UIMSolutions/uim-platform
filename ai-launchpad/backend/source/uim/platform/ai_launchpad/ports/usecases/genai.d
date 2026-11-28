/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the generative AI hub.
module uim.platform.ai_launchpad.ports.usecases.genai;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IManagePromptCollections : IManageResource!(PromptCollection, PromptCollectionId, PromptCollectionInput) {
}

interface IManagePrompts : IManageResource!(Prompt, PromptId, PromptInput) {
  /// Render the template with the inputs and complete it (playground).
  PromptRunResult run(TenantId t, PromptId id, string[string] inputs, UserId actor);
}
