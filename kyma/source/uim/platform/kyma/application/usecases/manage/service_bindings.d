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
class ManageServiceBindingsUseCase { // TODO: UIMUseCase {
  private ServiceBindingRepository repo;

  this(ServiceBindingRepository repo) {
    this.repo = repo;
  }

  CommandResult createServiceBinding(CreateServiceBindingRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Binding name is required");
    if (req.serviceInstanceId.isEmpty)
      return CommandResult(false, "", "Service instance ID is required");

    if (repo.existsByName(req.namespaceId, req.name))
      return CommandResult(false, "", "Binding '" ~ req.name ~ "' already exists");

    ServiceBinding binding;
    binding.initEntity(req.tenantId, req.createdBy);
    binding.serviceInstanceId = req.serviceInstanceId;
    binding.namespaceId = req.namespaceId;
    binding.environmentId = req.environmentId;
    binding.name = req.name;
    binding.description = req.description;
    binding.status = ServiceBindingStatus.creating;
    binding.secretName = req.secretName.length > 0 ? req.secretName : req.name ~ "-secret";
    binding.secretNamespace = req.secretNamespace;
    binding.parametersJson = req.parametersJson;
    binding.labels = req.labels;

    repo.save(binding);
    return CommandResult(true, binding.id.value, "");
  }

  CommandResult updateServiceBinding(ServiceBindingId id, UpdateServiceBindingRequest req) {
    auto binding = repo.findById(tenantId, id);
    if (binding.isNull)
      return CommandResult(false, "", "Service binding not found");

    if (req.description.length > 0)
      binding.description = req.description;
    if (req.secretName.length > 0)
      binding.secretName = req.secretName;
    if (req.parametersJson.length > 0)
      binding.parametersJson = req.parametersJson;
    if (req.labels !is null)
      binding.labels = req.labels;
    binding.updatedAt = clockSeconds();

    repo.update(binding);
    return CommandResult(true, id.value, "");
  }

  bool hasServiceBinding(ServiceBindingId id) {
    return repo.existsById(id);
  }

  ServiceBinding getServiceBinding(ServiceBindingId id) {
    return repo.findById(tenantId, id);
  }

  ServiceBinding[] listServiceBindingsByNamespace(NamespaceId nsId) {
    return repo.findByNamespace(nsId);
  }

  ServiceBinding[] listServiceBindingsByServiceInstance(ServiceInstanceId instId) {
    return repo.findByServiceInstance(instId);
  }

  CommandResult deleteServiceBinding(ServiceBindingId id) {
    auto binding = repo.findById(tenantId, id);
    if (binding.isNull)
      return CommandResult(false, "", "Service binding not found");

    repo.removeById(id);
    return CommandResult(true, id.value, "");
  }
}
