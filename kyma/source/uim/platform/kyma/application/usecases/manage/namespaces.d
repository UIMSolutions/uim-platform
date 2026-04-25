/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.namespaces;

// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.namespace;
// import uim.platform.kyma.domain.ports.repositories.namespaces;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for Kubernetes namespace management.
class ManageNamespacesUseCase { // TODO: UIMUseCase {
  private NamespaceRepository namespaceRepository;

  this(NamespaceRepository namespaceRepository) {
    this.namespaceRepository = namespaceRepository;
  }

  CommandResult create(CreateNamespaceRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Namespace name is required");

    if (req.environmentId.isEmpty)
      return CommandResult(false, "", "Environment ID is required");

    if (namespaceRepository.existsByName(req.environmentId, req.name))
      return CommandResult(false, "", "Namespace '" ~ req.name ~ "' already exists");

    Namespace ns;
    with (ns) {
      id = randomUUID();
      environmentId = req.environmentId;
      tenantId = req.tenantId;
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
      createdBy = req.createdBy;
      createdAt = clockSeconds();
      updatedAt = ns.createdAt;
    }

    namespaceRepository.save(ns);
    return CommandResult(true, ns.id.toString, "");
  }

  CommandResult updateNamespace(NamespaceId id, UpdateNamespaceRequest req) {
    if (!namespaceRepository.existsById(id))
      return CommandResult(false, "", "Namespace not found");

    auto ns = namespaceRepository.findById(id);
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
    return CommandResult(true, id.toString, "");
  }

  bool hasNamespace(string namespaceId) {
    return hasNamespace(NamespaceId(namespaceId));
  }

  bool hasNamespace(NamespaceId namespaceId) {
    return namespaceRepository.existsById(namespaceId);
  }

  Namespace getNamespace(string namespaceId) {
    return getNamespace(NamespaceId(namespaceId));
  }

  Namespace getNamespace(NamespaceId namespaceId) {
    return namespaceRepository.findById(namespaceId);
  }

  Namespace[] listByEnvironment(KymaEnvironmentId envId) {
    return namespaceRepository.findByEnvironment(envId);
  }

  Namespace[] listByEnvironment(string envId) {
    return listByEnvironment(KymaEnvironmentId(envId));
  } 

  CommandResult deleteNamespace(string namespaceId) {
    return deleteNamespace(NamespaceId(namespaceId));
  }

  CommandResult deleteNamespace(NamespaceId namespaceId) {
    if (!namespaceRepository.existsById(namespaceId))
      return CommandResult(false, "", "Namespace not found");

    namespaceRepository.remove(namespaceId);
    return CommandResult(true, namespaceId.toString, "");
  }

  private QuotaEnforcement parseQuotaEnforcement(string s) {
    switch (s) {
    case "enforce":
      return QuotaEnforcement.enforce;
    case "warn":
      return QuotaEnforcement.warn_;
    case "none":
      return QuotaEnforcement.none;
    default:
      return QuotaEnforcement.enforce;
    }
  }
}
