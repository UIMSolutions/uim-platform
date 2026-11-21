/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Deployments (AI API /lm/deployments): submit, stop/restart, configuration
/// rollout, delete, bulk patch.
module uim.platform.ai_core.application.usecases.manage.deployments;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// TTL bounds (seconds) — the AI API minimum is 10 minutes; 0 = unlimited.
enum long minTtlSeconds = 600;
enum long maxTtlSeconds = 365 * 24 * 3600;

class ManageDeploymentsUseCase : AiCoreInteractor, IManageDeployments {
  this(AiCoreRepositories repos, IClock clock, IAiCoreEventPublisher events, LifecyclePolicy policy) {
    super(repos, clock, events, policy);
  }

  Deployment createDeployment(CreateDeploymentRequest r) {
    auto t = r.tenantId, rg = r.resourceGroupId;
    provisionedGroupOf(t, rg);
    auto c = configurationOf(t, rg, ConfigurationId(r.configurationId.strip));
    requireServing(t, rg, c);
    if (r.ttlSeconds != 0)
      requireRange(r.ttlSeconds, minTtlSeconds, maxTtlSeconds, "ttl (seconds)");
    Deployment d;
    stampCreated!(Deployment, DeploymentId)(d, t, r.actor, newResourceId(), now);
    d.resourceGroupId = rg;
    d.configurationId = c.id;
    d.scenarioId = c.scenarioId;
    d.executableId = c.executableId;
    d.ttlSeconds = r.ttlSeconds;
    submitDeployment(d, now);
    repos.deployments.save(d);
    emit("deployment.submitted", t, resourceKey(rg.value, d.id.value), Json(["configurationId": Json(c.id.value)]));
    return d;
  }

  Deployment patchDeployment(PatchDeploymentRequest r) {
    auto t = r.tenantId, rg = r.resourceGroupId;
    auto d = getDeployment(t, rg, DeploymentId(r.id));
    if (r.targetStatus.strip.length == 0 && r.configurationId.strip.length == 0)
      throw AiCoreException.invalid("Either targetStatus or configurationId is required");
    if (r.targetStatus.strip.length > 0) {
      auto target = parseDomainEnum!TargetStatus(r.targetStatus, "targetStatus");
      if (target == TargetStatus.deleted) {
        deleteDeployment(t, rg, d.id);
        d.targetStatus = TargetStatus.deleted;
        d.lastOperation = DeploymentOperation.delete_;
        return d;
      }
      requestDeploymentTarget(d, target, now);
    }
    if (r.configurationId.strip.length > 0 && r.configurationId.strip != d.configurationId.value) {
      auto c = configurationOf(t, rg, ConfigurationId(r.configurationId.strip));
      if (c.scenarioId != d.scenarioId)
        throw AiCoreException.invalid("Configuration '" ~ c.id.value ~ "' belongs to another scenario");
      requireServing(t, rg, c);
      changeDeploymentConfiguration(d, c, now);
      d.executableId = c.executableId;
    }
    stampUpdated(d, r.actor, now);
    repos.deployments.save(d);
    emit("deployment.patched", t, resourceKey(rg.value, d.id.value), Json([
        "targetStatus": Json(cast(string) d.targetStatus), "configurationId": Json(d.configurationId.value)
      ]));
    return d;
  }

  BulkResult[] patchDeployments(TenantId t, ResourceGroupId rg, UserId actor, const string[] ids, string targetStatus) {
    return bulk(ids, (string id) {
      PatchDeploymentRequest r;
      r.tenantId = t;
      r.resourceGroupId = rg;
      r.actor = actor;
      r.id = id;
      r.targetStatus = targetStatus;
      patchDeployment(r);
    });
  }

  Deployment getDeployment(TenantId t, ResourceGroupId rg, DeploymentId id) {
    return required(repos.deployments.findById(t, rg, id), "Deployment '" ~ id.value ~ "'");
  }

  Deployment[] listDeployments(TenantId t, ResourceGroupId rg, RunFilter filter = RunFilter.init) {
    return repos.deployments.findByGroup(t, rg).filter!(d => filter.matches(d)).array;
  }

  void deleteDeployment(TenantId t, ResourceGroupId rg, DeploymentId id) {
    auto d = getDeployment(t, rg, id);
    if (!canDeleteDeployment(d))
      throw AiCoreException.ruleViolation("Deployment '" ~ id.value ~ "' is " ~ cast(string) d.status ~ "; stop it before deleting");
    repos.deployments.removeById(t, rg, id);
    emit("deployment.deleted", t, resourceKey(rg.value, id.value));
  }

  protected void requireServing(TenantId t, ResourceGroupId rg, const Configuration c) {
    auto executable = executableOf(t, rg, c.executableId);
    if (!executable.deployable)
      throw AiCoreException.ruleViolation("Executable '" ~ executable.id.value ~ "' is a workflow; create an execution instead");
  }
}
