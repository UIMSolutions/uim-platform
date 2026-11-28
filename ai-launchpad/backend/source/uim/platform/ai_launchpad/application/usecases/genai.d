/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The generative AI hub: prompt collections and prompts with a playground.
///
/// Collections belong to an active workspace and can only be deleted
/// without prompts. Changing the messages or the model of a prompt raises
/// its version. Running a prompt renders the template with the inputs (all
/// placeholders need a value) and completes it with the runtime; the output
/// is kept as the last result. The audit log records the run, never the
/// prompt or the output.
module uim.platform.ai_launchpad.application.usecases.genai;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class ManagePromptCollectionsUseCase : ResourceInteractor!(PromptCollection, PromptCollectionId, PromptCollectionInput),
IManagePromptCollections {
  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAilpRepository!(PromptCollection, PromptCollectionId) store() {
    return repos.promptCollections;
  }

  protected override string what() {
    return "Prompt collection";
  }

  protected override string eventPrefix() {
    return "promptCollection";
  }

  protected override string[] immutableAttributes() {
    return ["workspaceId"];
  }

  protected override PromptCollectionInput toInput(const PromptCollection e) {
    return PromptCollectionInput(e.workspaceId.value, e.name, e.description);
  }

  protected override void fromInput(TenantId t, ref PromptCollection e, PromptCollectionInput i, bool creating) {
    if (creating) {
      auto w = workspaceOf(t, i.workspaceId);
      w.requireActive("Creating a prompt collection");
      e.workspaceId = w.id;
    }
    e.name = i.name.strip.length ? i.name.strip : e.id.value;
    e.description = i.description.strip;
  }

  protected override void beforeRemove(TenantId t, const PromptCollection e, UserId actor) {
    requireUnused("Prompt collection '" ~ e.id.value ~ "'", repos.prompts.countByReference(t, "collectionId", e.id.value),
      "prompts");
  }
}

class ManagePromptsUseCase : ResourceInteractor!(Prompt, PromptId, PromptInput), IManagePrompts {
  protected IAiRuntime runtime;

  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy, IAiRuntime runtime) {
    super(repos, clock, audit, unitOfWork, policy);
    this.runtime = runtime;
  }

  protected override IAilpRepository!(Prompt, PromptId) store() {
    return repos.prompts;
  }

  protected override string what() {
    return "Prompt";
  }

  protected override string eventPrefix() {
    return "prompt";
  }

  protected override string[] immutableAttributes() {
    return ["collectionId"];
  }

  protected override PromptInput toInput(const Prompt e) {
    return PromptInput(e.collectionId.value, e.name, e.description, e.modelName, e.modelVersion, e.systemMessage,
      e.userMessage, e.temperature, e.maxTokens, e.topP, cast(string) e.status);
  }

  protected override void fromInput(TenantId t, ref Prompt e, PromptInput i, bool creating) {
    if (creating) {
      auto c = required(repos.promptCollections.findById(t, PromptCollectionId(i.collectionId.strip)),
        "Prompt collection '" ~ i.collectionId.strip ~ "'");
      e.collectionId = c.id;
    }
    e.name = i.name.strip.length ? i.name.strip : e.id.value;
    e.description = i.description.strip;
    e.modelName = i.modelName.strip;
    e.modelVersion = i.modelVersion.strip.length ? i.modelVersion.strip : "latest";
    e.systemMessage = i.systemMessage;
    e.userMessage = i.userMessage;
    e.temperature = i.temperature;
    e.maxTokens = i.maxTokens;
    e.topP = i.topP;
    e.status = parseDomainEnumOr!PromptStatus(i.status, PromptStatus.draft, "prompt status");
  }

  protected override void beforeSave(TenantId t, ref Prompt e, bool creating, const string[] changed) {
    if (creating)
      return;
    foreach (f; ["systemMessage", "userMessage", "modelName", "modelVersion"])
      if (changed.canFind(f)) {
        e.version_++;
        return;
      }
  }

  PromptRunResult run(TenantId t, PromptId id, string[string] inputs, UserId actor) {
    auto p = get(t, id);
    p.requireRunnable();
    string[string] values;
    foreach (k, v; inputs)
      values[k.strip] = v;
    auto system = renderTemplate(p.systemMessage, values);
    auto user = renderTemplate(p.userMessage, values);
    auto completion = runtime.complete(p, system, user);
    p.lastOutput = completion.output.length > 32_000 ? completion.output[0 .. 32_000] : completion.output;
    p.lastRunAt = now;
    p.runCount++;
    repos.prompts.save(p);
    emit("prompt.run", t, actor, id.value, Json([
        "version": Json(p.version_), "model": Json(p.modelName), "promptTokens": Json(completion.promptTokens),
        "completionTokens": Json(completion.completionTokens)
      ]));
    PromptRunResult r;
    r.promptId = id.value;
    r.promptVersion = p.version_;
    r.modelName = p.modelName;
    r.renderedPrompt = (system.length ? system ~ "\n\n" : "") ~ user;
    r.output = completion.output;
    r.promptTokens = completion.promptTokens;
    r.completionTokens = completion.completionTokens;
    r.latencyMs = completion.latencyMs;
    return r;
  }
}
