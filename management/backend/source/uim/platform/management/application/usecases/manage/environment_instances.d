/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.environment_instances;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Use case: manage environment instance lifecycle (CF, Kyma, ABAP).
/// The actual provisioning is delegated to the IProvisioningGateway port.
class ManageEnvironmentsUseCase : IManageEnvironmentsUseCase {
  protected IEnvironmentRepository repo;
  protected ISubaccountRepository subaccountRepo;
  protected EnvironmentProvisioner provisioner;
  protected IProvisioningGateway gateway;
  protected PlatformEventRecorder recorder;

  this(IEnvironmentRepository repo, ISubaccountRepository subaccountRepo, EnvironmentProvisioner provisioner,
      IProvisioningGateway gateway, PlatformEventRecorder recorder) {
    this.repo = repo;
    this.subaccountRepo = subaccountRepo;
    this.provisioner = provisioner;
    this.gateway = gateway;
    this.recorder = recorder;
  }

  UsecaseResult createEnvironment(CreateEnvironmentRequest req) {
    if (req.subaccountId.isEmpty)
      return invalid("Subaccount ID is required");
    if (req.name.length == 0)
      return invalid("Environment name is required");
    EnvironmentType envType = EnvironmentType.cloudFoundry;
    if (req.environmentType.length > 0 && !tryParseEnum!EnvironmentType(req.environmentType, envType))
      return invalid("Unknown environment type '" ~ req.environmentType ~ "' (expected "
          ~ enumNames!EnvironmentType().join(", ") ~ ")");
    if (req.memoryQuotaMb < 0 || req.routeQuota < 0 || req.serviceQuota < 0)
      return invalid("Quotas must not be negative");

    auto subaccount = subaccountRepo.findById(req.tenantId, req.subaccountId);
    if (subaccount.isNull)
      return notFound("Subaccount");

    auto validation = provisioner.validateProvisioning(envType, req.planName, subaccount,
      repo.findBySubaccount(req.tenantId, req.subaccountId));
    if (!validation.valid)
      return violation(validation.reason);

    auto inst = Environment(req.tenantId);
    inst.subaccountId = req.subaccountId;
    inst.globalAccountId = subaccount.globalAccountId;
    inst.name = req.name;
    inst.description = req.description;
    inst.environmentType = envType;
    inst.planName = req.planName;
    inst.landscapeLabel = req.landscapeLabel.length > 0 ? req.landscapeLabel : defaultLandscape(envType, subaccount.region);
    inst.platformRegion = subaccount.region;
    inst.status = EnvironmentStatus.creating;
    inst.memoryQuotaMb = req.memoryQuotaMb;
    inst.routeQuota = req.routeQuota;
    inst.serviceQuota = req.serviceQuota;
    inst.parameters = req.parameters;
    inst.labels = req.labels;
    inst.createdBy = actor(req.createdBy);
    inst.updatedBy = inst.createdBy;
    repo.save(inst);

    auto outcome = gateway.provisionEnvironment(inst, subaccount);
    if (outcome.success) {
      inst.status = EnvironmentStatus.active;
      inst.technicalKey = outcome.technicalKey;
      inst.dashboardUrl = outcome.url;
    } else {
      inst.status = EnvironmentStatus.error;
      inst.parameters["error"] = outcome.message;
    }
    inst.update();
    repo.update(inst);

    recorder.record(req.tenantId, PlatformEventRecorder.ofEnvironment(inst),
      EnvironmentEventCategory.environmentLifecycle,
      outcome.success ? "environment.created" : "environment.failed",
      (outcome.success ? "Environment provisioned: " : "Environment provisioning failed: ") ~ inst.name
      ~ " (" ~ enumName(envType) ~ ")",
      inst.createdBy, outcome.success ? EnvironmentEventSeverity.info : EnvironmentEventSeverity.error);

    if (!outcome.success)
      return UsecaseResult(false, inst.id.value, "Provisioning failed: " ~ outcome.message, ResultCode.ruleViolation);
    return created(inst.id.value, "Environment provisioned");
  }

  UsecaseResult updateEnvironment(UpdateEnvironmentRequest req) {
    auto instance = repo.findById(req.tenantId, req.instanceId);
    if (instance.isNull)
      return notFound("Environment instance");

    if (req.description.length > 0)
      instance.description = req.description;
    if (req.memoryQuotaMb > 0)
      instance.memoryQuotaMb = req.memoryQuotaMb;
    if (req.routeQuota > 0)
      instance.routeQuota = req.routeQuota;
    if (req.serviceQuota > 0)
      instance.serviceQuota = req.serviceQuota;
    if (req.parameters.length > 0)
      instance.parameters = req.parameters;
    if (req.labels.length > 0)
      instance.labels = req.labels;
    instance.update();

    repo.update(instance);
    recorder.record(req.tenantId, PlatformEventRecorder.ofEnvironment(instance),
      EnvironmentEventCategory.environmentLifecycle, "environment.updated",
      "Environment updated: " ~ instance.name, instance.updatedBy);
    return ok(instance.id.value, "Environment updated");
  }

  UsecaseResult deprovisionEnvironment(TenantId tenantId, EnvironmentId id) {
    auto instance = repo.findById(tenantId, id);
    if (instance.isNull)
      return notFound("Environment instance");
    if (!provisioner.canDelete(instance))
      return violation("Environment cannot be deleted in status '" ~ enumName(instance.status) ~ "'");

    instance.status = EnvironmentStatus.deleting;
    instance.update();
    repo.update(instance);

    auto outcome = gateway.deprovisionEnvironment(instance);
    if (!outcome.success) {
      instance.status = EnvironmentStatus.error;
      repo.update(instance);
      recorder.record(tenantId, PlatformEventRecorder.ofEnvironment(instance),
        EnvironmentEventCategory.environmentLifecycle, "environment.deprovisionFailed",
        "Deprovisioning failed: " ~ instance.name ~ " — " ~ outcome.message, UserId("system"), EnvironmentEventSeverity.error);
      return violation("Deprovisioning failed: " ~ outcome.message);
    }

    repo.remove(instance);
    recorder.record(tenantId, PlatformEventRecorder.ofEnvironment(instance),
      EnvironmentEventCategory.environmentLifecycle, "environment.deleted",
      "Environment deprovisioned: " ~ instance.name, UserId("system"));
    return ok(id.value, "Environment deprovisioned");
  }

  Environment getEnvironment(TenantId tenantId, EnvironmentId id) {
    return repo.findById(tenantId, id);
  }

  Environment[] listEnvironments(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Environment[] listEnvironments(TenantId tenantId, SubaccountId subId) {
    return repo.findBySubaccount(tenantId, subId);
  }

  Environment[] listEnvironments(TenantId tenantId, SubaccountId subId, string envType) {
    EnvironmentType t;
    if (!tryParseEnum!EnvironmentType(envType, t))
      return null;
    return repo.findByType(tenantId, subId, t);
  }

  /// e.g. cloudFoundry + eu10 → "cf-eu10"
  protected static string defaultLandscape(EnvironmentType type, string region) {
    final switch (type) {
    case EnvironmentType.cloudFoundry:
      return "cf-" ~ region;
    case EnvironmentType.kyma:
      return "kyma-" ~ region;
    case EnvironmentType.abap:
      return "abap-" ~ region;
    case EnvironmentType.neo:
      return "neo-" ~ region;
    }
  }
}
