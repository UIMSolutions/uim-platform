/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.environments;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.kyma_environment;
// import uim.platform.kyma.domain.ports.repositories.environments;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for Kyma environment lifecycle management.
class ManageEnvironmentsUseCase { // TODO: UIMUseCase {
  private EnvironmentRepository repo;

  this(EnvironmentRepository repo) {
    this.repo = repo;
  }

  CommandResult createEnvironment(CreateEnvironmentRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Environment name is required");
    if (req.plan.length == 0)
      return CommandResult(false, "", "Plan is required");
    if (req.region.length == 0)
      return CommandResult(false, "", "Region is required");

    KymaEnvironment env;
    env.initEntity(req.tenantId, req.createdBy);

    env.subaccountId = req.subaccountId;
    env.clusterId = "cluster-" ~ env.id.value[0 .. 8];
    env.name = req.name;
    env.description = req.description;
    env.plan = parsePlan(req.plan);
    env.region = req.region;
    env.status = EnvironmentStatus.provisioning;
    env.machineCount = req.machineCount > 0 ? req.machineCount : 3;
    env.machineType = req.machineType;
    env.autoScalerMin = req.autoScalerMin > 0 ? req.autoScalerMin : 3;
    env.autoScalerMax = req.autoScalerMax > 0 ? req.autoScalerMax : 20;
    env.oidcIssuerUrl = req.oidcIssuerUrl;
    env.oidcClientId = req.oidcClientId;
    env.oidcGroupsClaim = req.oidcGroupsClaim;
    env.oidcUsernameClaim = req.oidcUsernameClaim;
    env.administrators = req.administrators;

    repo.save(env);
    return CommandResult(true, env.id.value, "");
  }

  CommandResult updateEnvironment(TenantId tenantId, KymaEnvironmentId id, UpdateEnvironmentRequest req) {
    auto env = repo.findById(tenantId, id);
    if (env.isNull)
      return CommandResult(false, "", "Environment not found");

    if (req.description.length > 0)
      env.description = req.description;
    if (req.machineCount > 0)
      env.machineCount = req.machineCount;
    if (req.machineType.length > 0)
      env.machineType = req.machineType;
    if (req.autoScalerMin > 0)
      env.autoScalerMin = req.autoScalerMin;
    if (req.autoScalerMax > 0)
      env.autoScalerMax = req.autoScalerMax;
    if (req.oidcIssuerUrl.length > 0)
      env.oidcIssuerUrl = req.oidcIssuerUrl;
    if (req.oidcClientId.length > 0)
      env.oidcClientId = req.oidcClientId;
    if (req.administrators.length > 0)
      env.administrators = req.administrators;
    env.updatedAt = clockSeconds();

    repo.update(env);
    return CommandResult(true, env.id.value, "");
  }

  bool hasEnvironment(TenantId tenantId, KymaEnvironmentId id) {
    return repo.existsById(tenantId, id);
  }

  KymaEnvironment getEnvironment(TenantId tenantId, KymaEnvironmentId id) {
    return repo.findById(tenantId, id);
  }

  KymaEnvironment[] listEnvironments(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  KymaEnvironment[] listEnvironments(TenantId tenantId, SubaccountId subId) {
    return repo.findBySubaccount(tenantId, subId);
  }

  CommandResult deleteEnvironment(TenantId tenantId, KymaEnvironmentId id) {
    auto env = repo.findById(tenantId, id);
    if (env.isNull)
      return CommandResult(false, "", "Environment not found");

    repo.remove(env);
    return CommandResult(true, env.id.value, "");
  }

}


