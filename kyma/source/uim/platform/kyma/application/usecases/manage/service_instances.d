/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.service_instances;

// /* import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.service_instance;
// import uim.platform.kyma.domain.ports.repositories.service_instances;
 */
import uim.platform.kyma;

// mixin(ShowModule!());

@safe:
/// Application service for BTP service instance management in Kyma.
class ManageServiceInstancesUseCase { // TODO: UIMUseCase {
  private ServiceInstanceRepository repo;

  this(ServiceInstanceRepository repo) {
    this.repo = repo;
  }

  CommandResult createServiceInstance(CreateServiceInstanceRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Service instance name is required");
    if (req.serviceOfferingName.length == 0)
      return CommandResult(false, "", "Service offering name is required");
    if (req.servicePlanName.length == 0)
      return CommandResult(false, "", "Service plan name is required");

    if (repo.existsByName(req.namespaceId, req.name))
      return CommandResult(false, "", "Service instance '" ~ req.name ~ "' already exists");

    ServiceInstance inst;
    inst.initEntity(req.tenantId, req.createdBy);
    inst.namespaceId = req.namespaceId;
    inst.environmentId = req.environmentId;
    inst.name = req.name;
    inst.description = req.description;
    inst.status = ServiceInstanceStatus.creating;
    inst.serviceOfferingName = req.serviceOfferingName;
    inst.servicePlanName = req.servicePlanName;
    inst.servicePlanId = req.servicePlanId;
    inst.externalName = req.externalName;
    inst.parametersJson = req.parametersJson;
    inst.labels = req.labels;

    repo.save(inst);
    return CommandResult(true, inst.id.value, "");
  }

  CommandResult updateServiceInstance(UpdateServiceInstanceRequest req) {
    auto inst = repo.findById(req.tenantId, req.id);
    if (inst.isNull)
      return CommandResult(false, "", "Service instance not found");

    if (req.description.length > 0)
      inst.description = req.description;
    if (req.servicePlanName.length > 0)
      inst.servicePlanName = req.servicePlanName;
    if (req.servicePlanId.length > 0)
      inst.servicePlanId = req.servicePlanId;
    if (req.parametersJson.length > 0)
      inst.parametersJson = req.parametersJson;
    if (req.labels !is null)
      inst.labels = req.labels;
    inst.status = ServiceInstanceStatus.updating;
    inst.updatedAt = clockSeconds();

    repo.update(inst);
    return CommandResult(true, id.value, "");
  }

  bool hasServiceInstance(TenantId tenantId, ServiceInstanceId id) {
    return repo.existsById(tenantId, id);
  }

  ServiceInstance getServiceInstance(TenantId tenantId, ServiceInstanceId id) {
    return repo.findById(tenantId, id);
  }

  ServiceInstance[] listServiceInstances(TenantId tenantId, NamespaceId nsId) {
    return repo.findByNamespace(tenantId, nsId);
  }

  ServiceInstance[] listServiceInstances(TenantId tenantId, KymaEnvironmentId envId) {
    return repo.findByEnvironment(tenantId, envId);
  }

  CommandResult deleteServiceInstance(TenantId tenantId, ServiceInstanceId id) {
    auto inst = repo.findById(tenantId, id);
    if (inst.isNull)
      return CommandResult(false, "", "Service instance not found");
      
    repo.remove(inst);
    return CommandResult(true, id.value, "");
  }
}


