/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// State machines of resource groups, executions and deployments.
///
/// Requests (submit, stop, restart) change the target state synchronously;
/// the runtime progress (PENDING → RUNNING → COMPLETED/STOPPED) happens in
/// advance(), driven by the reconciler worker. The LifecyclePolicy holds the
/// simulated runtime durations.
module uim.platform.ai_core.domain.services.lifecycle;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct LifecyclePolicy {
  long provisionSeconds = 0; /// resource group PROVISIONING → PROVISIONED (0 = synchronous)
  long executionStartSeconds = 2; /// execution PENDING → RUNNING
  long executionRunSeconds = 30; /// execution RUNNING → COMPLETED
  long deploymentStartSeconds = 5; /// deployment PENDING → RUNNING
  string inferenceBaseUrl = "http://localhost:8090/api/v2/inference"; /// prefix of deployment URLs
}

/// What advance() changed.
enum Transition {
  none,
  started,
  completed,
  stopped,
  expired, /// deployment TTL elapsed
  provisioned
}

// ── Resource groups ─────────────────────────────────────────────────────────

Transition advanceResourceGroup(ref ResourceGroup g, long now, const LifecyclePolicy p) {
  if (g.status == ResourceGroupStatus.provisioning && now >= plusSeconds(g.createdAt, p.provisionSeconds)) {
    g.status = ResourceGroupStatus.provisioned;
    g.statusMessage = "Resource group provisioned";
    return Transition.provisioned;
  }
  return Transition.none;
}

// ── Executions ──────────────────────────────────────────────────────────────

void submitExecution(ref Execution e, long now) {
  e.status = ExecutionStatus.pending;
  e.targetStatus = TargetStatus.completed;
  e.submissionTime = now;
  e.statusMessage = "Execution submitted";
}

/// PATCH targetStatus=STOPPED.
void requestExecutionStop(ref Execution e, long now) {
  final switch (e.status) {
  case ExecutionStatus.pending:
    e.status = ExecutionStatus.stopped;
    e.completionTime = now;
    e.statusMessage = "Stopped before start";
    break;
  case ExecutionStatus.running:
    e.status = ExecutionStatus.stopping;
    e.statusMessage = "Stop requested";
    break;
  case ExecutionStatus.stopping, ExecutionStatus.stopped:
    break;
  case ExecutionStatus.unknown, ExecutionStatus.completed, ExecutionStatus.dead:
    throw AiCoreException.ruleViolation("Execution in status " ~ cast(string) e.status ~ " cannot be stopped");
  }
  e.targetStatus = TargetStatus.stopped;
}

/// Executions holding runtime resources cannot be deleted (stop them first).
bool canDeleteExecution(const Execution e) {
  return !isActive(e.status);
}

Transition advanceExecution(ref Execution e, long now, const LifecyclePolicy p) {
  switch (e.status) {
  case ExecutionStatus.pending:
    if (e.targetStatus == TargetStatus.completed && now >= plusSeconds(e.submissionTime, p.executionStartSeconds)) {
      e.status = ExecutionStatus.running;
      e.startTime = now;
      e.statusMessage = "Execution running";
      return Transition.started;
    }
    break;
  case ExecutionStatus.running:
    if (now >= plusSeconds(e.startTime, p.executionRunSeconds)) {
      e.status = ExecutionStatus.completed;
      e.completionTime = now;
      e.statusMessage = "Execution completed successfully";
      return Transition.completed;
    }
    break;
  case ExecutionStatus.stopping:
    e.status = ExecutionStatus.stopped;
    e.completionTime = now;
    e.statusMessage = "Execution stopped";
    return Transition.stopped;
  default:
    break;
  }
  return Transition.none;
}

// ── Deployments ─────────────────────────────────────────────────────────────

void submitDeployment(ref Deployment d, long now) {
  d.status = DeploymentStatus.pending;
  d.targetStatus = TargetStatus.running;
  d.lastOperation = DeploymentOperation.create;
  d.submissionTime = now;
  d.statusMessage = "Deployment submitted";
}

/// PATCH targetStatus=STOPPED | RUNNING.
void requestDeploymentTarget(ref Deployment d, TargetStatus target, long now) {
  switch (target) {
  case TargetStatus.stopped:
    final switch (d.status) {
    case DeploymentStatus.pending:
      d.status = DeploymentStatus.stopped;
      d.completionTime = now;
      d.statusMessage = "Stopped before start";
      break;
    case DeploymentStatus.running:
      d.status = DeploymentStatus.stopping;
      d.statusMessage = "Stop requested";
      break;
    case DeploymentStatus.stopping, DeploymentStatus.stopped:
      break;
    case DeploymentStatus.unknown, DeploymentStatus.completed, DeploymentStatus.dead:
      throw AiCoreException.ruleViolation("Deployment in status " ~ cast(string) d.status ~ " cannot be stopped");
    }
    break;
  case TargetStatus.running:
    if (d.status == DeploymentStatus.stopping)
      throw AiCoreException.ruleViolation("Deployment is stopping; wait for STOPPED before restarting");
    if (d.status == DeploymentStatus.stopped || d.status == DeploymentStatus.dead || d.status == DeploymentStatus.unknown) {
      d.status = DeploymentStatus.pending;
      d.submissionTime = now;
      d.startTime = 0;
      d.completionTime = 0;
      d.statusMessage = "Restart requested";
      d.lastOperation = DeploymentOperation.update;
    }
    break;
  default:
    throw AiCoreException.invalid("Target status of a deployment must be RUNNING or STOPPED, not " ~ cast(string) target);
  }
  d.targetStatus = target;
}

/// PATCH configurationId: roll out a new serving configuration.
void changeDeploymentConfiguration(ref Deployment d, const Configuration c, long now) {
  if (d.status == DeploymentStatus.stopping)
    throw AiCoreException.ruleViolation("Deployment is stopping; the configuration cannot be changed");
  d.configurationId = c.id;
  d.lastOperation = DeploymentOperation.update;
  if (d.status == DeploymentStatus.running || d.status == DeploymentStatus.pending) {
    d.status = DeploymentStatus.pending;
    d.submissionTime = now;
    d.statusMessage = "Rolling out configuration " ~ c.id.value;
  }
}

bool canDeleteDeployment(const Deployment d) {
  return !isActive(d.status);
}

Transition advanceDeployment(ref Deployment d, long now, const LifecyclePolicy p) {
  switch (d.status) {
  case DeploymentStatus.pending:
    if (d.targetStatus == TargetStatus.running && now >= plusSeconds(d.submissionTime, p.deploymentStartSeconds)) {
      d.status = DeploymentStatus.running;
      d.startTime = now;
      d.latestRunningConfigurationId = d.configurationId;
      d.deploymentUrl = p.inferenceBaseUrl.stripRight("/") ~ "/deployments/" ~ d.id.value;
      d.statusMessage = "Deployment running";
      return Transition.started;
    }
    break;
  case DeploymentStatus.running:
    auto expiry = d.expiresAt;
    if (expiry > 0 && now >= expiry) {
      d.status = DeploymentStatus.stopped;
      d.targetStatus = TargetStatus.stopped;
      d.completionTime = now;
      d.statusMessage = "Stopped after its time to live of " ~ d.ttlSeconds.to!string ~ "s";
      return Transition.expired;
    }
    break;
  case DeploymentStatus.stopping:
    d.status = DeploymentStatus.stopped;
    d.completionTime = now;
    d.statusMessage = "Deployment stopped";
    return Transition.stopped;
  default:
    break;
  }
  return Transition.none;
}

// ── Schedules ───────────────────────────────────────────────────────────────

/// Compute the first run of a (re)activated schedule.
void planSchedule(ref ExecutionSchedule s, long now) {
  if (!s.isActive) {
    s.nextRunAt = 0;
    return;
  }
  auto from = s.startTime > now ? s.startTime - 1 : now;
  auto next = CronExpression.parse(s.cron).next(from);
  s.nextRunAt = s.endTime > 0 && next > s.endTime ? 0 : next;
}

bool isScheduleDue(const ExecutionSchedule s, long now) {
  return s.isActive && s.nextRunAt > 0 && s.nextRunAt <= now && s.inWindow(now);
}

/// Record a run and plan the next one.
void recordScheduleRun(ref ExecutionSchedule s, ExecutionId execution, long now) {
  s.lastRunAt = now;
  s.lastExecutionId = execution;
  planSchedule(s, now);
}

///
unittest {
  LifecyclePolicy p;
  p.executionStartSeconds = 1;
  p.executionRunSeconds = 10;
  auto t0 = parseIsoTime("2026-01-01T00:00:00Z");

  Execution e;
  submitExecution(e, t0);
  assert(advanceExecution(e, t0, p) == Transition.none);
  assert(advanceExecution(e, plusSeconds(t0, 1), p) == Transition.started);
  assert(advanceExecution(e, plusSeconds(t0, 5), p) == Transition.none);
  assert(!canDeleteExecution(e));
  assert(advanceExecution(e, plusSeconds(t0, 11), p) == Transition.completed && e.durationSeconds(0) == 10);
  assert(canDeleteExecution(e));
  assert(failsWith(AiCoreErrorKind.ruleViolation, () { requestExecutionStop(e, t0); }));

  Execution s;
  submitExecution(s, t0);
  requestExecutionStop(s, t0);
  assert(s.status == ExecutionStatus.stopped && s.targetStatus == TargetStatus.stopped);

  Deployment d;
  d.id = DeploymentId("d1");
  d.ttlSeconds = 60;
  submitDeployment(d, t0);
  assert(advanceDeployment(d, plusSeconds(t0, 5), p) == Transition.started);
  assert(d.deploymentUrl.endsWith("/deployments/d1"));
  assert(advanceDeployment(d, plusSeconds(t0, 66), p) == Transition.expired && d.status == DeploymentStatus.stopped);
  requestDeploymentTarget(d, TargetStatus.running, plusSeconds(t0, 70));
  assert(d.status == DeploymentStatus.pending && d.lastOperation == DeploymentOperation.update);
  assert(advanceDeployment(d, plusSeconds(t0, 75), p) == Transition.started);
  requestDeploymentTarget(d, TargetStatus.stopped, plusSeconds(t0, 80));
  assert(d.status == DeploymentStatus.stopping && !canDeleteDeployment(d));
  assert(failsWith(AiCoreErrorKind.ruleViolation, () { requestDeploymentTarget(d, TargetStatus.running, t0); }));
  assert(advanceDeployment(d, plusSeconds(t0, 81), p) == Transition.stopped && canDeleteDeployment(d));
  assert(failsWith(AiCoreErrorKind.invalid, () { requestDeploymentTarget(d, TargetStatus.completed, t0); }));

  ExecutionSchedule sch;
  sch.cron = "0 * * * *";
  planSchedule(sch, t0);
  assert(isoTimeText(sch.nextRunAt) == "2026-01-01T01:00:00Z");
  assert(!isScheduleDue(sch, t0) && isScheduleDue(sch, sch.nextRunAt));
  recordScheduleRun(sch, ExecutionId("x"), sch.nextRunAt);
  assert(isoTimeText(sch.nextRunAt) == "2026-01-01T02:00:00Z");
  sch.endTime = parseIsoTime("2026-01-01T01:30:00Z");
  planSchedule(sch, sch.lastRunAt);
  assert(sch.nextRunAt == 0);
}
