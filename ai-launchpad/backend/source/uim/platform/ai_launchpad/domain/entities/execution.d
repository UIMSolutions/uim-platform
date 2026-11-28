/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An execution runs the training executable of a configuration in a
/// resource group of the runtime.
///
///   pending ──start──▶ running ──complete──▶ completed | failed
///      └─────────────────┴──stop──▶ stopped
module uim.platform.ai_launchpad.domain.entities.execution;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Execution {
  mixin TenantEntity!ExecutionId;

  ConfigurationId configurationId;
  ScenarioId scenarioId; /// derived from the configuration
  ConnectionId connectionId; /// derived from the configuration
  ResourceGroupId resourceGroupId;
  ExecutionStatus status = ExecutionStatus.pending;
  string statusMessage;
  long startedAt;
  long completedAt;
  long durationSeconds;

  /// Pending or running (occupies the resource group).
  bool isActive() const {
    return status == ExecutionStatus.pending || status == ExecutionStatus.running;
  }

  bool isFinished() const {
    return !isActive;
  }

  void start(long now) {
    if (status != ExecutionStatus.pending)
      throw AilpException.ruleViolation("Execution '" ~ id.value ~ "' is " ~ cast(string) status ~ ", not pending");
    status = ExecutionStatus.running;
    startedAt = now;
    statusMessage = "Running";
  }

  void complete(long now, bool succeeded, string message) {
    if (status != ExecutionStatus.running)
      throw AilpException.ruleViolation("Execution '" ~ id.value ~ "' is " ~ cast(string) status ~ ", not running");
    status = succeeded ? ExecutionStatus.completed : ExecutionStatus.failed;
    completedAt = now;
    durationSeconds = secondsBetween(startedAt, now);
    statusMessage = message;
  }

  void stop(long now, string by) {
    if (!isActive)
      throw AilpException.ruleViolation("Execution '" ~ id.value ~ "' is already " ~ cast(string) status);
    status = ExecutionStatus.stopped;
    completedAt = now;
    durationSeconds = secondsBetween(startedAt, now);
    statusMessage = "Stopped by " ~ by;
  }

  void validate() const {
    requireId(id.value, "Execution ID");
    requireId(configurationId.value, "Configuration");
    requireId(resourceGroupId.value, "Resource group");
    requireMaxLength(statusMessage, 2000, "Status message");
  }
}

///
unittest {
  Execution e;
  e.id = ExecutionId("e1");
  e.configurationId = ConfigurationId("cfg");
  e.resourceGroupId = ResourceGroupId("default");
  e.validate();
  assert(e.isActive);
  e.start(plusSeconds(1, 0));
  e.complete(plusSeconds(1, 90), true, "Model trained");
  assert(e.status == ExecutionStatus.completed && e.durationSeconds == 90 && e.isFinished);
  assert(failsWith(AilpErrorKind.ruleViolation, () { e.stop(2, "ada"); }));
  Execution p;
  p.stop(5, "ada");
  assert(p.status == ExecutionStatus.stopped && p.statusMessage == "Stopped by ada");
}
