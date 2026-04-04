/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.environments;

import uim.platform.kyma.application.dto;
import uim.platform.kyma.domain.entities.kyma_environment;
import uim.platform.kyma.domain.ports.environment_repository;
import uim.platform.kyma.domain.types;

/// Application service for Kyma environment lifecycle management.
class ManageEnvironmentsUseCase
{
  private EnvironmentRepository repo;

  this(EnvironmentRepository repo)
  {
    this.repo = repo;
  }

  CommandResult create(CreateEnvironmentRequest req)
  {
    if (req.name.length == 0)
      return CommandResult(false, "", "Environment name is required");
    if (req.plan.length == 0)
      return CommandResult(false, "", "Plan is required");
    if (req.region.length == 0)
      return CommandResult(false, "", "Region is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    KymaEnvironment env;
    env.id = id;
    env.tenantId = req.tenantId;
    env.subaccountId = req.subaccountId;
    env.clusterId = "cluster-" ~ id[0 .. 8];
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
    env.createdBy = req.createdBy;
    env.createdAt = clockSeconds();
    env.modifiedAt = env.createdAt;

    repo.save(env);
    return CommandResult(true, id, "");
  }

  CommandResult updateEnvironment(KymaEnvironmentId id, UpdateEnvironmentRequest req)
  {
    auto env = repo.findById(id);
    if (env.id.length == 0)
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
    env.modifiedAt = clockSeconds();

    repo.update(env);
    return CommandResult(true, id, "");
  }

  KymaEnvironment getEnvironment(KymaEnvironmentId id)
  {
    return repo.findById(id);
  }

  KymaEnvironment[] listByTenant(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  KymaEnvironment[] listBySubaccount(TenantId tenantId, SubaccountId subId)
  {
    return repo.findBySubaccount(tenantId, subId);
  }

  CommandResult deleteEnvironment(KymaEnvironmentId id)
  {
    auto env = repo.findById(id);
    if (env.id.length == 0)
      return CommandResult(false, "", "Environment not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private KymaPlan parsePlan(string s)
  {
    switch (s)
    {
    case "azure":
      return KymaPlan.azure;
    case "aws":
      return KymaPlan.aws;
    case "gcp":
      return KymaPlan.gcp;
    case "sapConvergedCloud":
      return KymaPlan.sapConvergedCloud;
    case "free":
      return KymaPlan.free_;
    case "trial":
      return KymaPlan.trial;
    default:
      return KymaPlan.azure;
    }
  }
}

private long clockSeconds()
{
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 10_000_000;
}
