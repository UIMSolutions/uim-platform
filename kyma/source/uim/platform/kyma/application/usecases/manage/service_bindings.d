/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.service_bindings;

/* import uim.platform.kyma.application.dto;
import uim.platform.kyma.domain.entities.service_binding;
import uim.platform.kyma.domain.ports.repositories.service_bindings;
import uim.platform.kyma.domain.types; */
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for service binding management.
class ManageServiceBindingsUseCase : UIMUseCase {
  private ServiceBindingRepository repo;

  this(ServiceBindingRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateServiceBindingRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Binding name is required");
    if (req.serviceInstanceId.length == 0)
      return CommandResult(false, "", "Service instance ID is required");

    auto existing = repo.findByName(req.namespaceId, req.name);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Binding '" ~ req.name ~ "' already exists");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    ServiceBinding binding;
    binding.id = id;
    binding.serviceInstanceId = req.serviceInstanceId;
    binding.namespaceId = req.namespaceId;
    binding.environmentId = req.environmentId;
    binding.tenantId = req.tenantId;
    binding.name = req.name;
    binding.description = req.description;
    binding.status = ServiceBindingStatus.creating;
    binding.secretName = req.secretName.length > 0 ? req.secretName : req.name ~ "-secret";
    binding.secretNamespace = req.secretNamespace;
    binding.parametersJson = req.parametersJson;
    binding.labels = req.labels;
    binding.createdBy = req.createdBy;
    binding.createdAt = clockSeconds();
    binding.modifiedAt = binding.createdAt;

    repo.save(binding);
    return CommandResult(true, id, "");
  }

  CommandResult updateBinding(ServiceBindingId id, UpdateServiceBindingRequest req) {
    auto binding = repo.findById(id);
    if (binding.id.length == 0)
      return CommandResult(false, "", "Service binding not found");

    if (req.description.length > 0)
      binding.description = req.description;
    if (req.secretName.length > 0)
      binding.secretName = req.secretName;
    if (req.parametersJson.length > 0)
      binding.parametersJson = req.parametersJson;
    if (req.labels !is null)
      binding.labels = req.labels;
    binding.modifiedAt = clockSeconds();

    repo.update(binding);
    return CommandResult(true, id, "");
  }

  ServiceBinding getBinding(ServiceBindingId id) {
    return repo.findById(id);
  }

  ServiceBinding[] listByNamespace(NamespaceId nsId) {
    return repo.findByNamespace(nsId);
  }

  ServiceBinding[] listByServiceInstance(ServiceInstanceId instId) {
    return repo.findByServiceInstance(instId);
  }

  CommandResult deleteBinding(ServiceBindingId id) {
    auto binding = repo.findById(id);
    if (binding.id.length == 0)
      return CommandResult(false, "", "Service binding not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }
}

private long clockSeconds() {
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 10_000_000;
}
