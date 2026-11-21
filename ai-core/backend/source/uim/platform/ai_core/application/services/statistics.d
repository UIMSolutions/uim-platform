/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.services.statistics;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class AiCoreStatisticsService : IAiCoreStatisticsService {
  protected AiCoreRepositories repos;
  protected IClock clock;

  this(AiCoreRepositories repos, IClock clock) {
    this.repos = repos;
    this.clock = clock;
  }

  AiCoreStatistics compute(TenantId t) {
    AiCoreStatistics s;
    s.tenantId = t.value;
    s.resourceGroups = repos.resourceGroups.countAll(t);
    s.scenarios = repos.scenarios.countAll(t);
    s.executables = repos.executables.countAll(t);
    s.configurations = repos.configurations.countAll(t);
    foreach (e; repos.executions.findAll(t)) {
      s.executions++;
      switch (e.status) {
      case ExecutionStatus.pending:
        s.pendingExecutions++;
        break;
      case ExecutionStatus.running, ExecutionStatus.stopping:
        s.runningExecutions++;
        break;
      case ExecutionStatus.completed:
        s.completedExecutions++;
        break;
      case ExecutionStatus.dead, ExecutionStatus.stopped:
        s.failedExecutions++;
        break;
      default:
        break;
      }
    }
    foreach (d; repos.deployments.findAll(t)) {
      s.deployments++;
      if (d.status == DeploymentStatus.running)
        s.runningDeployments++;
      else if (d.status == DeploymentStatus.stopped || d.status == DeploymentStatus.dead)
        s.stoppedDeployments++;
    }
    foreach (a; repos.artifacts.findAll(t)) {
      s.artifacts++;
      if (a.kind == ArtifactKind.model)
        s.models++;
      else if (a.kind == ArtifactKind.dataset)
        s.datasets++;
    }
    foreach (sch; repos.schedules.findAll(t)) {
      s.schedules++;
      if (sch.isActive)
        s.activeSchedules++;
    }
    s.metrics = repos.metrics.countAll(t);
    s.secrets = repos.dockerSecrets.countAll(t) + repos.objectStoreSecrets.countAll(t);
    s.computedAt = clock.now();
    return s;
  }
}
