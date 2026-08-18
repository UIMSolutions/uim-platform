/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.environment_instances;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.environment_instance;
// import uim.platform.management.domain.entities.subaccount;
// import uim.platform.management.domain.ports.repositories.environment_instances;
// import uim.platform.management.domain.ports.repositories.subaccounts;
// import uim.platform.management.domain.services.environment_provisioner;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage environment instance lifecycle (CF, Kyma, ABAP).
class ManageEnvironmentsUseCase {
  protected IEnvironmentRepository repo;
  private ISubaccountRepository subaccountRepo;
  private EnvironmentProvisioner provisioner;

  this(IEnvironmentRepository repo, ISubaccountRepository subaccountRepo,
      EnvironmentProvisioner provisioner) {
    this.repo = repo;
    this.subaccountRepo = subaccountRepo;
    this.provisioner = provisioner;
  }

  UsecaseResult createEnvironment(CreateEnvironmentRequest req) {
    if (req.subaccountId.isEmpty)
      return UsecaseResult(false, "", "Subaccount ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Environment name is required");

    auto subaccount = subaccountRepo.findById(req.tenantId, req.subaccountId);
    if (subaccount.isNull)
      return UsecaseResult(false, "", "Subaccount not found");

    auto envType = req.environmentType.toEnvironmentType;
    auto existing = repo.findBySubaccount(req.tenantId, req.subaccountId);

    auto validation = provisioner.validateProvisioning(envType, req.planName,
        subaccount, existing);
    if (!validation.valid)
      return UsecaseResult(false, "", validation.reason);

    auto inst = Environment(req.tenantId);
    inst.subaccountId = req.subaccountId;
    inst.globalAccountId = req.globalAccountId;
    inst.name = req.name;
    inst.description = req.description;
    inst.environmentType = envType;
    inst.planName = req.planName;
    inst.landscapeLabel = req.landscapeLabel;
    inst.status = EnvironmentStatus.creating;
    inst.memoryQuotaMb = req.memoryQuotaMb;
    inst.routeQuota = req.routeQuota;
    inst.serviceQuota = req.serviceQuota;
    inst.parameters = req.parameters;
    inst.labels = req.labels;
    inst.createdBy = req.createdBy;
    inst.updatedBy = req.createdBy;

    repo.save(inst);

    // Transition to active (simulated provisioning)
    inst.status = EnvironmentStatus.active;
    inst.dashboardUrl = "/environments/" ~ inst.id.value ~ "/dashboard";
    inst.technicalKey = "env-" ~ inst.id.value[0 .. 8];
    repo.update(inst);

    return UsecaseResult(true, inst.id.value, "");
  }

  UsecaseResult updateEnvironment(UpdateEnvironmentRequest req) {
    auto instance = repo.findById(req.tenantId, req.instanceId);
    if (instance.isNull)
      return UsecaseResult(false, "", "Environment instance not found");

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
    instance.updatedAt = clockSeconds();

    repo.update(instance);
    return UsecaseResult(true, instance.id.value, "");
  }
  
  UsecaseResult deprovisionEnvironment(TenantId tenantId, EnvironmentId id) {
    auto instance = repo.findById(tenantId, id);
    if (instance.isNull)
      return UsecaseResult(false, "", "Environment instance not found");
    if (!provisioner.canDelete(instance))
      return UsecaseResult(false, "", "Environment cannot be deleted in current status");

    instance.status = EnvironmentStatus.deleting;
    instance.updatedAt = clockSeconds();
    repo.update(instance);

    // Complete deletion
    repo.remove(instance);
    return UsecaseResult(true, id.value, "");
  }

  Environment getEnvironment(TenantId tenantId, EnvironmentId id) {
    return repo.findById(tenantId, id);
  }

  Environment[] listEnvironments(TenantId tenantId, SubaccountId subId) {
    return repo.findBySubaccount(tenantId, subId);
  }

  Environment[] listEnvironments(TenantId tenantId, SubaccountId subId, string envType) {
    return repo.findByType(tenantId, subId, envType.toEnvironmentType);
  }
}

///
unittest {
    auto environmentRepository = new EnvironmentRepository();
    auto subaccountRepository = new SubaccountRepository();
    auto environmentProvisioner = new EnvironmentProvisioner();
    auto usecase = new ManageEnvironmentsUseCase(environmentRepository, subaccountRepository, environmentProvisioner);
    auto tenantId = TenantId("test-tenant");

    assert(usecase !is null);
}
