/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration scenarios and their task templates.
///
/// Rules: task templates change only while their scenario is a draft (copy
/// an active scenario to change it); a scenario is activated with at least
/// one template and a consistent dependency graph; the category, version
/// and system types of a non-draft scenario are frozen; scenarios with
/// workflows cannot be deleted (archive them).
module uim.platform.integration_automation.application.usecases.scenarios;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class ManageScenariosUseCase : ResourceInteractor!(IntegrationScenario, ScenarioId, ScenarioInput), IManageScenarios {
  this(IaRepositories repos, IClock clock, IIaEventPublisher events, IIaUnitOfWork unitOfWork, IaPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IIaRepository!(IntegrationScenario, ScenarioId) store() {
    return repos.scenarios;
  }

  protected override string what() {
    return "Scenario";
  }

  protected override string eventPrefix() {
    return "scenario";
  }

  protected override ScenarioInput toInput(const IntegrationScenario e) {
    ScenarioInput i;
    i.name = e.name;
    i.description = e.description;
    i.category = cast(string) e.category;
    i.version_ = e.version_;
    i.sourceSystemType = cast(string) e.sourceSystemType;
    i.targetSystemType = cast(string) e.targetSystemType;
    i.prerequisites = e.prerequisites.dup;
    return i;
  }

  protected override void fromInput(TenantId t, ref IntegrationScenario e, ScenarioInput i, bool creating) {
    auto category = parseDomainEnum!ScenarioCategory(i.category, "category");
    auto source = parseDomainEnum!SystemType(i.sourceSystemType, "source system type");
    auto target = parseDomainEnum!SystemType(i.targetSystemType, "target system type");
    if (!creating && !e.isDraft && (category != e.category || i.version_.strip != e.version_
        || source != e.sourceSystemType || target != e.targetSystemType))
      throw IaException.ruleViolation("Scenario '" ~ e.id.value ~ "' is " ~ cast(string) e.status
          ~ " — category, version and system types can only change in a draft (copy it)");
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.category = category;
    e.version_ = i.version_.strip;
    e.sourceSystemType = source;
    e.targetSystemType = target;
    e.prerequisites = uniqueTexts(i.prerequisites);
  }

  protected override void beforeRemove(TenantId t, const IntegrationScenario e, UserId actor) {
    requireUnused("Scenario '" ~ e.id.value ~ "'", repos.workflows.countByReference(t, "scenarioId", e.id.value),
      "workflows — archive it instead");
    foreach (tpl; repos.scenarioTasks.findByReference(t, "scenarioId", e.id.value))
      repos.scenarioTasks.removeById(t, tpl.id);
  }

  IntegrationScenario activate(TenantId t, ScenarioId id, UserId actor) {
    auto s = get(t, id);
    auto templates = repos.scenarioTasks.findByReference(t, "scenarioId", id.value);
    foreach (tpl; templates)
      checkTemplateDependencies(tpl, templates);
    s.activate(templates.length, now);
    return changed(t, s, actor, "activated");
  }

  IntegrationScenario deprecate(TenantId t, ScenarioId id, UserId actor) {
    auto s = get(t, id);
    s.deprecate();
    return changed(t, s, actor, "deprecated");
  }

  IntegrationScenario archive(TenantId t, ScenarioId id, UserId actor) {
    auto s = get(t, id);
    s.archive();
    return changed(t, s, actor, "archived");
  }

  IntegrationScenario copy(TenantId t, ScenarioId id, string newId, UserId actor) {
    auto source = get(t, id);
    auto copyId = idOrNew(newId, "Scenario ID");
    if (repos.scenarios.existsById(t, ScenarioId(copyId)))
      throw IaException.conflict("Scenario '" ~ copyId ~ "' already exists");
    IntegrationScenario s = source;
    s.prerequisites = source.prerequisites.dup;
    stampCreated!(IntegrationScenario, ScenarioId)(s, t, actor, copyId, now);
    s.status = ScenarioStatus.draft;
    s.activatedAt = 0;
    s.basedOnId = source.id;
    s.version_ = nextVersion(source.version_);
    s.validate();
    batch(() {
      repos.scenarios.save(s);
      auto templates = repos.scenarioTasks.findByReference(t, "scenarioId", id.value);
      string[string] mapped;
      foreach (tpl; templates)
        mapped[tpl.id.value] = newResourceId();
      foreach (tpl; templates) {
        ScenarioTask c = tpl;
        stampCreated!(ScenarioTask, ScenarioTaskId)(c, t, actor, mapped[tpl.id.value], now);
        c.scenarioId = s.id;
        c.dependsOn = tpl.dependsOn.map!(d => mapped.get(d, d)).array;
        repos.scenarioTasks.save(c);
      }
    });
    emit("scenario.copied", t, s.id.value, Json(["from": Json(id.value)]));
    return s;
  }

  long[string] templateCounts(TenantId t) {
    long[string] counts;
    foreach (tpl; repos.scenarioTasks.findAll(t))
      counts[tpl.scenarioId.value]++;
    return counts;
  }

  protected IntegrationScenario changed(TenantId t, IntegrationScenario s, UserId actor, string verb) {
    stampUpdated(s, actor, now);
    repos.scenarios.save(s);
    emit("scenario." ~ verb, t, s.id.value);
    return s;
  }
}

/// "1.0" → "1.1", "2" → "2.1", "v3.9" → "v3.10", anything else gets ".1".
string nextVersion(string v) {
  auto dot = v.lastIndexOf('.');
  if (dot >= 0 && dot + 1 < v.length && v[dot + 1 .. $].all!(c => c >= '0' && c <= '9'))
    return v[0 .. dot + 1] ~ (v[dot + 1 .. $].to!long + 1).to!string;
  return v ~ ".1";
}

class ManageScenarioTasksUseCase : ResourceInteractor!(ScenarioTask, ScenarioTaskId, ScenarioTaskInput), IManageScenarioTasks {
  this(IaRepositories repos, IClock clock, IIaEventPublisher events, IIaUnitOfWork unitOfWork, IaPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IIaRepository!(ScenarioTask, ScenarioTaskId) store() {
    return repos.scenarioTasks;
  }

  protected override string what() {
    return "Task template";
  }

  protected override string eventPrefix() {
    return "scenarioTask";
  }

  protected override string[] immutableAttributes() {
    return ["scenarioId"];
  }

  protected override ScenarioTaskInput toInput(const ScenarioTask e) {
    ScenarioTaskInput i;
    i.scenarioId = e.scenarioId.value;
    i.sequenceNumber = e.sequenceNumber;
    i.name = e.name;
    i.description = e.description;
    i.taskType = cast(string) e.taskType;
    i.priority = cast(string) e.priority;
    i.assignedRole = e.assignedRole;
    i.instructions = e.instructions;
    i.destinationId = e.destinationId.value;
    i.automationEndpoint = e.automationEndpoint;
    i.automationPayload = e.automationPayload;
    i.requiresSourceSystem = e.requiresSourceSystem;
    i.requiresTargetSystem = e.requiresTargetSystem;
    i.afterPrevious = e.afterPrevious;
    i.dependsOn = e.dependsOn.dup;
    i.estimatedMinutes = e.estimatedMinutes;
    return i;
  }

  protected override void fromInput(TenantId t, ref ScenarioTask e, ScenarioTaskInput i, bool creating) {
    if (i.scenarioId.strip.length == 0)
      throw IaException.invalid("Scenario is required");
    auto scenario = draftScenario(t, ScenarioId(i.scenarioId.strip));
    e.scenarioId = scenario.id;
    e.sequenceNumber = i.sequenceNumber;
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.taskType = parseDomainEnum!TaskType(i.taskType, "task type");
    e.priority = parseDomainEnum!TaskPriority(i.priority, "priority");
    e.assignedRole = i.assignedRole.strip;
    e.instructions = i.instructions;
    e.destinationId = DestinationId(optionalReference!DestinationId(repos.destinations, t, i.destinationId, "Destination"));
    e.automationEndpoint = i.automationEndpoint.strip;
    e.automationPayload = i.automationPayload;
    e.requiresSourceSystem = i.requiresSourceSystem;
    e.requiresTargetSystem = i.requiresTargetSystem;
    e.afterPrevious = i.afterPrevious;
    e.dependsOn = uniqueTexts(i.dependsOn);
    e.estimatedMinutes = i.estimatedMinutes;

    // the whole graph of the scenario must stay consistent
    auto all = repos.scenarioTasks.findByReference(t, "scenarioId", scenario.id.value).filter!(o => o.id != e.id).array ~ e;
    foreach (o; all)
      checkTemplateDependencies(o, all);
  }

  protected override void beforeRemove(TenantId t, const ScenarioTask e, UserId actor) {
    draftScenario(t, e.scenarioId);
    foreach (o; repos.scenarioTasks.findByReference(t, "scenarioId", e.scenarioId.value))
      if (o.dependsOn.canFind(e.id.value))
        throw IaException.ruleViolation("Task template '" ~ o.id.value ~ "' depends on '" ~ e.id.value ~ "'");
  }

  ScenarioTask[] listOf(TenantId t, ScenarioId scenario) {
    auto templates = repos.scenarioTasks.findByReference(t, "scenarioId", scenario.value);
    templates.sort!((a, b) => a.sequenceNumber != b.sequenceNumber ? a.sequenceNumber < b.sequenceNumber : a.id.value < b.id.value);
    return templates;
  }

  protected IntegrationScenario draftScenario(TenantId t, ScenarioId id) {
    auto s = required(repos.scenarios.findById(t, id), "Scenario '" ~ id.value ~ "'");
    if (!s.isDraft)
      throw IaException.ruleViolation("Scenario '" ~ id.value ~ "' is " ~ cast(string) s.status
          ~ " — task templates can only change in a draft (copy the scenario)");
    return s;
  }
}

/// Trimmed, de-duplicated texts (order kept).
string[] uniqueTexts(const string[] values) {
  string[] result;
  foreach (v; values) {
    auto t = v.strip;
    if (t.length && !result.canFind(t))
      result ~= t;
  }
  return result;
}

///
unittest {
  assert(nextVersion("1.0") == "1.1" && nextVersion("v3.9") == "v3.10" && nextVersion("2") == "2.1");
  assert(uniqueTexts([" a", "b", "a", ""]) == ["a", "b"]);
}
