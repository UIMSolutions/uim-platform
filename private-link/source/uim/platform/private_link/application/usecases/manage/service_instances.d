/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.application.usecases.manage.service_instances;
import uim.platform.private_link;

// mixin(ShowModule!());

@safe:
/// Use case: full lifecycle management of private link service instances.
class ManageServiceInstancesUseCase {
  private ServiceInstanceRepository instances;
  private PrivateEndpointRepository endpoints;

  this(ServiceInstanceRepository instances, PrivateEndpointRepository endpoints) {
    this.instances = instances;
    this.endpoints = endpoints;
  }

  CommandResult createInstance(CreateServiceInstanceRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Name is required");
    if (req.resourceId.length == 0)
      return CommandResult(false, "", "resourceId is required");
    if (instances.existsByName(req.tenantId, req.name))
      return CommandResult(false, "", "Service instance with this name already exists");

    auto inst = ServiceInstance();
    inst.id = ServiceInstanceId(generateId());
    inst.tenantId = req.tenantId;
    inst.name = req.name;
    inst.description = req.description;
    inst.resourceId = req.resourceId;
    inst.iaasProvider = toIaasProvider(req.iaasProvider);
    inst.plan = toServicePlan(req.plan);
    inst.region = req.region;
    inst.subaccountId = req.subaccountId;
    inst.status = InstanceStatus.pending;
    inst.createdAt = currentTimeMs();
    inst.updatedAt = inst.createdAt;

    instances.save(inst);
    return CommandResult(true, inst.id.value, "Service instance created");
  }

  CommandResult updateInstance(UpdateServiceInstanceRequest req) {
    auto inst = instances.findById(req.tenantId, req.instanceId);
    if (inst.id.value.length == 0)
      return CommandResult(false, "", "Service instance not found");

    auto updated = inst;
    if (req.description.length > 0)
      updated.description = req.description;
    if (req.statusMessage.length > 0)
      updated.statusMessage = req.statusMessage;
    updated.updatedAt = currentTimeMs();

    instances.update(updated);
    return CommandResult(true, req.instanceId.value, "Service instance updated");
  }

  CommandResult deleteInstance(TenantId tenantId, ServiceInstanceId id) {
    auto inst = instances.findById(tenantId, id);
    if (inst.id.value.length == 0)
      return CommandResult(false, "", "Service instance not found");

    endpoints.removeByServiceInstance(tenantId, id);
    instances.remove(inst);
    return CommandResult(true, id.value, "Service instance deleted");
  }

  ServiceInstance getInstance(TenantId tenantId, ServiceInstanceId id) {
    return instances.findById(tenantId, id);
  }

  ServiceInstance getByName(TenantId tenantId, string name) {
    return instances.findByName(tenantId, name);
  }

  ServiceInstance[] listInstances(TenantId tenantId) {
    return instances.find(tenantId);
  }

  ServiceInstance[] listByStatus(TenantId tenantId, InstanceStatus status) {
    return instances.findByStatus(tenantId, status);
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  private IaasProvider toIaasProvider(string s) {
    switch (s) {
      case "aws": return IaasProvider.aws;
      case "gcp": return IaasProvider.gcp;
      default:    return IaasProvider.azure;
    }
  }

  private ServicePlan toServicePlan(string s) {
    return s == "premium" ? ServicePlan.premium : ServicePlan.standard;
  }
}
