/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.namespaces;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.namespace;
// import uim.platform.kyma.domain.ports.repositories.namespaces;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for Kubernetes namespace management.
class ManageNamespacesUseCase { // TODO: UIMUseCase {
  private NamespaceRepository namespaceRepository;

  this(NamespaceRepository namespaceRepository) {
    this.namespaceRepository = namespaceRepository;
  }

  CommandResult createNamespace(CreateNamespaceRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Namespace name is required");

    if (req.environmentId.isEmpty)
      return CommandResult(false, "", "Environment ID is required");

    if (namespaceRepository.existsByName(req.environmentId, req.name))
      return CommandResult(false, "", "Namespace '" ~ req.name ~ "' already exists");

    auto ns = Namespace(req.tenantId); //, req.createdBy);
    with (ns) {
      environmentId = req.environmentId;
      name = req.name;
      description = req.description;
      status = NamespaceStatus.active;
      cpuLimit = req.cpuLimit;
      memoryLimit = req.memoryLimit;
      cpuRequest = req.cpuRequest;
      memoryRequest = req.memoryRequest;
      podLimit = req.podLimit > 0 ? req.podLimit : 100;
      quotaEnforcement = parseQuotaEnforcement(req.quotaEnforcement);
      istioInjection = req.istioInjection;
      labels = req.labels;
      annotations = req.annotations;
    }

    namespaceRepository.save(ns);
    return CommandResult(true, ns.id.value, "");
  }

  CommandResult updateNamespace(UpdateNamespaceRequest req) {
    auto ns = namespaceRepository.findById(req.tenantId, req.id);
    if (ns.isNull)
      return CommandResult(false, "", "Namespace not found");

    if (req.description.length > 0)
      ns.description = req.description;
    if (req.cpuLimit.length > 0)
      ns.cpuLimit = req.cpuLimit;
    if (req.memoryLimit.length > 0)
      ns.memoryLimit = req.memoryLimit;
    if (req.cpuRequest.length > 0)
      ns.cpuRequest = req.cpuRequest;
    if (req.memoryRequest.length > 0)
      ns.memoryRequest = req.memoryRequest;
    if (req.podLimit > 0)
      ns.podLimit = req.podLimit;
    if (req.quotaEnforcement.length > 0)
      ns.quotaEnforcement = parseQuotaEnforcement(req.quotaEnforcement);
    ns.istioInjection = req.istioInjection;
    if (req.labels !is null)
      ns.labels = req.labels;
    if (req.annotations !is null)
      ns.annotations = req.annotations;
    ns.updatedAt = clockSeconds();

    namespaceRepository.update(ns);
    return CommandResult(true, ns.id.value, "");
  }

  bool hasNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return namespaceRepository.existsById(tenantId, namespaceId);
  }

  Namespace getNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return namespaceRepository.findById(tenantId, namespaceId);
  }

  Namespace[] listNamespaces(TenantId tenantId, KymaEnvironmentId envId) {
    return namespaceRepository.findByEnvironment(envId);
  }

  CommandResult deleteNamespace(TenantId tenantId, NamespaceId namespaceId) {
    auto ns = namespaceRepository.findById(tenantId, namespaceId);
    if (ns.isNull)
      return CommandResult(false, "", "Namespace not found");

    namespaceRepository.remove(ns);
    return CommandResult(true, ns.id.value, "");
  }
}
