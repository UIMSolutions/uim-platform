/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration scenarios and their task templates.
///
/// A scenario is the reusable definition of an integration (e.g. "Connect
/// SAP S/4HANA Cloud with SAP SuccessFactors"). Its task templates are the
/// guided steps; workflows are instantiated from active scenarios and copy
/// the templates into their own tasks.
module uim.platform.integration_automation.domain.entities.scenario;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

struct IntegrationScenario {
  mixin TenantEntity!ScenarioId;

  string name;
  string description;
  ScenarioCategory category = ScenarioCategory.custom;
  string version_ = "1.0";
  ScenarioStatus status = ScenarioStatus.draft;
  SystemType sourceSystemType = SystemType.any_; /// required type of the source system ("any": no restriction)
  SystemType targetSystemType = SystemType.any_;
  string[] prerequisites;
  ScenarioId basedOnId; /// the scenario this one was copied from
  long activatedAt;

  bool isDraft() const {
    return status == ScenarioStatus.draft;
  }

  bool isActive() const {
    return status == ScenarioStatus.active;
  }

  /// draft → active (needs at least one task template).
  void activate(size_t templates, long at) {
    if (status != ScenarioStatus.draft && status != ScenarioStatus.deprecated_)
      throw IaException.ruleViolation("Scenario '" ~ id.value ~ "' is " ~ cast(string) status ~ " — only draft or deprecated "
          ~ "scenarios can be activated");
    if (templates == 0)
      throw IaException.ruleViolation("Scenario '" ~ id.value ~ "' has no task templates");
    status = ScenarioStatus.active;
    activatedAt = at;
  }

  /// active → deprecated (no new workflows).
  void deprecate() {
    if (status != ScenarioStatus.active)
      throw IaException.ruleViolation("Only active scenarios can be deprecated");
    status = ScenarioStatus.deprecated_;
  }

  /// draft | deprecated → archived.
  void archive() {
    if (status == ScenarioStatus.active)
      throw IaException.ruleViolation("Deprecate scenario '" ~ id.value ~ "' before archiving it");
    if (status == ScenarioStatus.archived)
      throw IaException.ruleViolation("Scenario '" ~ id.value ~ "' is already archived");
    status = ScenarioStatus.archived;
  }

  void validate() const {
    requireId(id.value, "Scenario ID");
    requireText(name, "Name");
    requireMaxLength(name, 256, "Name");
    requireMaxLength(description, 4000, "Description");
    requireText(version_, "Version");
    requireMaxLength(version_, 32, "Version");
    foreach (p; prerequisites)
      requireMaxLength(p, 1000, "Prerequisite");
  }
}

/// A guided step of a scenario, copied into every workflow.
struct ScenarioTask {
  mixin TenantEntity!ScenarioTaskId;

  ScenarioId scenarioId;
  int sequenceNumber = 10; /// order within the scenario (10, 20, …)
  string name;
  string description;
  TaskType taskType = TaskType.manual;
  TaskPriority priority = TaskPriority.medium;
  string assignedRole; /// role responsible (e.g. "Integration Expert")
  string instructions; /// what to do, step by step
  DestinationId destinationId; /// automated tasks: base URL of the call
  string automationEndpoint; /// automated tasks: path (with destination) or absolute URL
  string automationPayload; /// automated tasks: request body (JSON text)
  bool requiresSourceSystem;
  bool requiresTargetSystem;
  bool afterPrevious = true; /// depends on the tasks with the next lower sequence number
  string[] dependsOn; /// further task templates (ids) of the same scenario
  int estimatedMinutes = 15;

  void validate() const {
    requireId(id.value, "Task template ID");
    if (scenarioId.isNull)
      throw IaException.invalid("Scenario is required");
    requireRange(sequenceNumber, 1, 9999, "Sequence number");
    requireText(name, "Name");
    requireMaxLength(name, 256, "Name");
    requireMaxLength(description, 4000, "Description");
    requireMaxLength(instructions, 20_000, "Instructions");
    requireMaxLength(assignedRole, 128, "Assigned role");
    requireMaxLength(automationEndpoint, 2048, "Automation endpoint");
    requireMaxLength(automationPayload, 100_000, "Automation payload");
    requireRange(estimatedMinutes, 0, 100_000, "Estimated minutes");
    if (taskType == TaskType.automated) {
      requireText(automationEndpoint, "Automation endpoint (automated task)");
      if (destinationId.isNull && !isHttpUrl(automationEndpoint))
        throw IaException.invalid("An automated task needs a destination or an absolute http(s) endpoint");
    }
    foreach (d; dependsOn) {
      requireId(d, "Dependency");
      if (d == id.value)
        throw IaException.invalid("Task template '" ~ id.value ~ "' cannot depend on itself");
    }
  }
}

///
unittest {
  IntegrationScenario s;
  s.id = ScenarioId("s4-sf");
  s.name = "S/4HANA ↔ SuccessFactors";
  s.validate();
  assert(failsWith(IaErrorKind.ruleViolation, () { s.activate(0, 1); }));
  s.activate(2, 1);
  assert(s.isActive && s.activatedAt == 1);
  assert(failsWith(IaErrorKind.ruleViolation, () { s.archive(); }));
  s.deprecate();
  s.archive();
  assert(s.status == ScenarioStatus.archived);

  ScenarioTask t;
  t.id = ScenarioTaskId("t1");
  t.scenarioId = s.id;
  t.name = "Call API";
  t.taskType = TaskType.automated;
  assert(failsWith(IaErrorKind.invalid, () { t.validate(); }));
  t.automationEndpoint = "https://api.example.com/run";
  t.validate();
  t.dependsOn = ["t1"];
  assert(failsWith(IaErrorKind.invalid, () { t.validate(); }));
}
