/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// KPIs of a tenant (launchpad tiles, app headers, CLI "stats").
module uim.platform.ai_launchpad.application.services.statistics;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class AilpStatisticsService : IAilpStatisticsService {
  protected AilpRepositories repos;
  protected IClock clock;

  this(AilpRepositories repos, IClock clock) {
    this.repos = repos;
    this.clock = clock;
  }

  AilpStatistics compute(TenantId t) {
    AilpStatistics s;
    s.tenantId = t;
    auto now = clock.now;
    s.workspaces = repos.workspaces.countAll(t);
    auto connections = repos.connections.findAll(t);
    s.connections = connections.length;
    s.activeConnections = connections.count!(c => c.isActive);
    s.resourceGroups = repos.resourceGroups.countAll(t);
    s.scenarios = repos.scenarios.countAll(t);
    s.configurations = repos.configurations.countAll(t);
    auto executions = repos.executions.findAll(t);
    s.executions = executions.length;
    s.runningExecutions = executions.count!(e => e.isActive);
    s.failedExecutions = executions.count!(e => e.status == ExecutionStatus.failed);
    auto deployments = repos.deployments.findAll(t);
    s.deployments = deployments.length;
    s.runningDeployments = deployments.count!(d => d.status == DeploymentStatus.running);
    s.models = repos.models.countAll(t);
    s.datasets = repos.datasets.countAll(t);
    s.promptCollections = repos.promptCollections.countAll(t);
    auto prompts = repos.prompts.findAll(t);
    s.prompts = prompts.length;
    s.activePrompts = prompts.count!(p => p.status == PromptStatus.active);
    s.promptRuns = prompts.map!(p => cast(long) p.runCount).sum;
    auto users = repos.users.findAll(t);
    s.users = users.length;
    s.lockedUsers = users.count!(u => u.isLockedAt(now));
    s.roles = repos.roles.countAll(t);
    s.tiles = repos.tiles.countAll(t);
    auto since = plusDays(now, -1);
    s.logEntriesLast24h = repos.logs.countSince(t, since);
    s.warningsLast24h = repos.logs.countSince(t, since, true);
    return s;
  }
}
