/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.deployments;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageDeploymentsUseCase : IManageDeploymentsUseCase {
  protected IDeploymentRepository repo;
  protected IAppVersionRepository versions;
  protected IDeviceRepository devices;
  protected IAgentryEventPublisher events;

  /// versions / devices may be null (no release checks / target resolution).
  this(IDeploymentRepository repo, IAppVersionRepository versions = null, IDeviceRepository devices = null,
      IAgentryEventPublisher events = null) {
    this.repo = repo;
    this.versions = versions;
    this.devices = devices;
    this.events = events is null ? new NullEventPublisher : events;
  }

  Deployment[] listDeployments(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Deployment[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
    return repo.findByMobileApplication(tenantId, appId);
  }

  Deployment[] listByStatus(TenantId tenantId, DeploymentStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  Deployment getDeployment(TenantId tenantId, DeploymentId id) {
    return repo.findById(tenantId, id);
  }

  UsecaseResult createDeployment(DeploymentDTO dto) {
    return guarded(() {
      if (!dto.deploymentId.isNull && repo.existsById(dto.tenantId, dto.deploymentId))
        return conflict("Deployment '" ~ dto.deploymentId.value ~ "' already exists");

      auto dep = newEntity!(Deployment)(dto.tenantId, dto.deploymentId, dto.createdBy);
      dep.mobileApplicationId = dto.applicationId;
      dep.appVersionId = dto.versionId;
      dep.deployedBy = dto.deployedBy.isNull ? dto.createdBy : dto.deployedBy;
      dep.status = DeploymentStatus.pending;

      // the application can be derived from the version
      if (versions !is null && !dto.versionId.isNull) {
        auto ver = versions.findById(dto.tenantId, dto.versionId);
        if (ver.isNull)
          return rejected("App version '" ~ dto.versionId.value ~ "' does not exist");
        if (dep.mobileApplicationId.isNull)
          dep.mobileApplicationId = ver.mobileApplicationId;
        else if (dep.mobileApplicationId != ver.mobileApplicationId)
          return rejected("App version '" ~ ver.id.value ~ "' belongs to another application");
        if (ver.status != AppVersionStatus.published)
          return rejected("Only published versions can be deployed (version " ~ ver.versionNumber
            ~ " is " ~ enumValue(ver.status) ~ ")");
      }

      string[] errors;
      apply(dep, dto, errors);
      if (dto.status.length > 0 && dto.status != "pending")
        errors ~= "new deployments start as pending — use startDeployment";
      errors ~= AgentryValidator.validate(dep);
      if (errors.length)
        return invalid(errors);

      repo.save(dep);
      return created(dep.id.value, "Deployment planned");
    });
  }

  UsecaseResult updateDeployment(DeploymentDTO dto) {
    return guarded(() {
      auto dep = repo.findById(dto.tenantId, dto.deploymentId);
      if (dep.isNull)
        return notFound("Deployment", dto.deploymentId.value);

      string[] errors;
      if (dep.status == DeploymentStatus.pending)
        apply(dep, dto, errors);
      else {
        assignIf(dep.notes, dto.notes);
      }
      DeploymentStatus status = dep.status;
      readEnum(dto.status, status, "status", errors);
      errors ~= AgentryValidator.validate(dep);
      if (errors.length)
        return invalid(errors);
      if (status != dep.status)
        return rejected("Use start / complete / rollback to change the deployment status");

      touch(dep, dto.updatedBy);
      repo.update(dep);
      return succeeded(dep.id.value, "Deployment updated");
    });
  }

  UsecaseResult startDeployment(TenantId tenantId, DeploymentId id, UserId by) {
    return guarded(() {
      auto dep = repo.findById(tenantId, id);
      if (dep.isNull)
        return notFound("Deployment", id.value);
      ensureTransition("Deployment", dep.status, DeploymentStatus.deploying);

      if (versions !is null) {
        auto ver = versions.findById(tenantId, dep.appVersionId);
        if (ver.isNull || ver.status != AppVersionStatus.published)
          return rejected("App version '" ~ dep.appVersionId.value ~ "' is no longer published");
      }
      if (devices !is null) {
        auto targets = targetDevices(dep);
        if (targets.length == 0)
          return rejected("The deployment does not target any enrolled device");
        dep.devicesTotal = targets.length;
      }

      dep.status = DeploymentStatus.deploying;
      dep.startedAt = nowStdTime();
      dep.completedAt = 0;
      dep.devicesSucceeded = 0;
      dep.devicesFailed = 0;
      touch(dep, by);
      repo.update(dep);
      events.publish(AgentryTopics.deploymentStarted, Json.emptyObject
          .set("tenantId", tenantId.value).set("id", id.value)
          .set("appVersionId", dep.appVersionId.value).set("devices", dep.devicesTotal));
      return succeeded(dep.id.value, "Deployment started for %d device(s)".format(dep.devicesTotal));
    });
  }

  UsecaseResult completeDeployment(TenantId tenantId, DeploymentId id, long devicesSucceeded, long devicesFailed) {
    return guarded(() {
      auto dep = repo.findById(tenantId, id);
      if (dep.isNull)
        return notFound("Deployment", id.value);
      if (devicesSucceeded < 0 || devicesFailed < 0)
        return invalid("device counts must not be negative");
      if (dep.devicesTotal > 0 && devicesSucceeded + devicesFailed > dep.devicesTotal)
        return invalid("more results (%d) than targeted devices (%d)".format(devicesSucceeded + devicesFailed,
          dep.devicesTotal));

      auto target = devicesSucceeded == 0 && devicesFailed > 0 ? DeploymentStatus.failed : DeploymentStatus.deployed;
      ensureTransition("Deployment", dep.status, target);
      dep.status = target;
      dep.devicesSucceeded = devicesSucceeded;
      dep.devicesFailed = devicesFailed;
      dep.completedAt = nowStdTime();
      dep.update();
      repo.update(dep);
      events.publish(AgentryTopics.deploymentFinished, Json.emptyObject
          .set("tenantId", tenantId.value).set("id", id.value).set("status", enumValue(target))
          .set("succeeded", devicesSucceeded).set("failed", devicesFailed));
      return succeeded(dep.id.value, "Deployment " ~ enumValue(target));
    });
  }

  UsecaseResult rollbackDeployment(TenantId tenantId, DeploymentId id, UserId by) {
    return guarded(() {
      auto dep = repo.findById(tenantId, id);
      if (dep.isNull)
        return notFound("Deployment", id.value);
      ensureTransition("Deployment", dep.status, DeploymentStatus.rolledBack);

      // the version that was live before this deployment
      auto previous = repo.findByMobileApplication(tenantId, dep.mobileApplicationId)
        .filter!(d => d.id != dep.id && d.status == DeploymentStatus.deployed
            && d.appVersionId != dep.appVersionId && d.completedAt <= dep.startedAt)
        .array
        .sort!((a, b) => a.completedAt > b.completedAt)
        .array;
      dep.rollbackVersionId = previous.length ? previous[0].appVersionId.value : "";
      dep.status = DeploymentStatus.rolledBack;
      dep.completedAt = nowStdTime();
      touch(dep, by);
      repo.update(dep);
      events.publish(AgentryTopics.deploymentRolledBack, Json.emptyObject
          .set("tenantId", tenantId.value).set("id", id.value).set("rollbackVersionId", dep.rollbackVersionId));
      return succeeded(dep.id.value, dep.rollbackVersionId.length
          ? "Deployment rolled back to version " ~ dep.rollbackVersionId
          : "Deployment rolled back (no previous version)");
    });
  }

  UsecaseResult deleteDeployment(TenantId tenantId, DeploymentId id) {
    auto dep = repo.findById(tenantId, id);
    if (dep.isNull)
      return notFound("Deployment", id.value);
    if (dep.status == DeploymentStatus.deploying)
      return rejected("A running deployment cannot be deleted", id.value);
    repo.remove(dep);
    return succeeded(dep.id.value, "Deployment deleted");
  }

  /// Devices addressed by the deployment scope (never removed ones).
  protected MobileDevice[] targetDevices(const Deployment dep) {
    auto candidates = devices.findByMobileApplication(dep.tenantId, dep.mobileApplicationId)
      .filter!(d => d.status != DeviceStatus.removed);
    final switch (dep.scope_) {
    case DeploymentScope.device:
      return candidates.filter!(d => d.id.value == dep.targetDeviceId).array;
    case DeploymentScope.group:
      return candidates.filter!(d => d.groupName == dep.targetGroupName).array;
    case DeploymentScope.tenant:
      return candidates.array;
    }
  }

  protected void apply(ref Deployment dep, const DeploymentDTO dto, ref string[] errors) {
    assignIf(dep.targetDeviceId, dto.targetDeviceId);
    assignIf(dep.targetGroupName, dto.targetGroupName);
    assignIf(dep.notes, dto.notes);
    if (dto.scheduledAt > 0)
      dep.scheduledAt = dto.scheduledAt;
    readEnum(dto.scope_, dep.scope_, "scope", errors);
  }
}

///
unittest {
  mixin(ShowTest!("ManageDeploymentsUseCase"));

  auto t = TenantId("t1");
  auto app = MobileApplicationId("app-1");
  auto versions = new AppVersionRepository();
  auto v1 = AppVersion(t, AppVersionId("v1"));
  v1.mobileApplicationId = app;
  v1.versionNumber = "1.0";
  versions.save(v1);

  auto devices = new DeviceRepository();
  foreach (i, group; ["north", "north", "south"]) {
    auto d = MobileDevice(t, DeviceId("d" ~ i.to!string));
    d.mobileApplicationId = app;
    d.groupName = group;
    devices.save(d);
  }

  auto uc = new ManageDeploymentsUseCase(new DeploymentRepository(), versions, devices);
  DeploymentDTO dto;
  dto.tenantId = t;
  dto.versionId = v1.id;
  dto.scope_ = "group";
  dto.targetGroupName = "north";
  assert(uc.createDeployment(dto).code == 422); // version not published

  v1.status = AppVersionStatus.published;
  versions.update(v1);
  auto r = uc.createDeployment(dto);
  assert(r.isSuccess, r.message);
  auto id = DeploymentId(r.id);
  assert(uc.getDeployment(t, id).mobileApplicationId == app); // derived from version

  assert(uc.completeDeployment(t, id, 2, 0).code == 422); // not started
  assert(uc.startDeployment(t, id, UserId("u")).isSuccess);
  assert(uc.getDeployment(t, id).devicesTotal == 2);
  assert(uc.completeDeployment(t, id, 2, 1).code == 400); // more than targeted
  assert(uc.completeDeployment(t, id, 2, 0).isSuccess);
  assert(uc.getDeployment(t, id).status == DeploymentStatus.deployed);
  assert(uc.rollbackDeployment(t, id, UserId("u")).isSuccess);
  assert(uc.startDeployment(t, id, UserId("u")).code == 422); // terminal
}
