/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.service_instances;

import uim.platform.kyma.application.dto;
import uim.platform.kyma.domain.entities.service_instance;
import uim.platform.kyma.domain.ports.repositories.service_instances;
import uim.platform.kyma.domain.types;

/// Application service for BTP service instance management in Kyma.
class ManageServiceInstancesUseCase : UIMUseCase {
  private ServiceInstanceRepository repo;

  this(ServiceInstanceRepository repo)
  {
    this.repo = repo;
  }

  CommandResult create(CreateServiceInstanceRequest req)
  {
    if (req.name.length == 0)
      return CommandResult(false, "", "Service instance name is required");
    if (req.serviceOfferingName.length == 0)
      return CommandResult(false, "", "Service offering name is required");
    if (req.servicePlanName.length == 0)
      return CommandResult(false, "", "Service plan name is required");

    auto existing = repo.findByName(req.namespaceId, req.name);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Service instance '" ~ req.name ~ "' already exists");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    ServiceInstance inst;
    inst.id = id;
    inst.namespaceId = req.namespaceId;
    inst.environmentId = req.environmentId;
    inst.tenantId = req.tenantId;
    inst.name = req.name;
    inst.description = req.description;
    inst.status = ServiceInstanceStatus.creating;
    inst.serviceOfferingName = req.serviceOfferingName;
    inst.servicePlanName = req.servicePlanName;
    inst.servicePlanId = req.servicePlanId;
    inst.externalName = req.externalName;
    inst.parametersJson = req.parametersJson;
    inst.labels = req.labels;
    inst.createdBy = req.createdBy;
    inst.createdAt = clockSeconds();
    inst.modifiedAt = inst.createdAt;

    repo.save(inst);
    return CommandResult(true, id, "");
  }

  CommandResult updateServiceInstance(ServiceInstanceId id, UpdateServiceInstanceRequest req)
  {
    auto inst = repo.findById(id);
    if (inst.id.length == 0)
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
    inst.modifiedAt = clockSeconds();

    repo.update(inst);
    return CommandResult(true, id, "");
  }

  ServiceInstance getServiceInstance(ServiceInstanceId id)
  {
    return repo.findById(id);
  }

  ServiceInstance[] listByNamespace(NamespaceId nsId)
  {
    return repo.findByNamespace(nsId);
  }

  ServiceInstance[] listByEnvironment(KymaEnvironmentId envId)
  {
    return repo.findByEnvironment(envId);
  }

  CommandResult deleteServiceInstance(ServiceInstanceId id)
  {
    auto inst = repo.findById(id);
    if (inst.id.length == 0)
      return CommandResult(false, "", "Service instance not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }
}

private long clockSeconds() {
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 10_000_000;
}
