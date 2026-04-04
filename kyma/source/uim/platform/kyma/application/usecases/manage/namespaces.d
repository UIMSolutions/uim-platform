/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.namespaces;

import uim.platform.kyma.application.dto;
import uim.platform.kyma.domain.entities.namespace;
import uim.platform.kyma.domain.ports.namespace_repository;
import uim.platform.kyma.domain.types;

/// Application service for Kubernetes namespace management.
class ManageNamespacesUseCase
{
  private NamespaceRepository repo;

  this(NamespaceRepository repo)
  {
    this.repo = repo;
  }

  CommandResult create(CreateNamespaceRequest req)
  {
    if (req.name.length == 0)
      return CommandResult(false, "", "Namespace name is required");
    if (req.environmentId.length == 0)
      return CommandResult(false, "", "Environment ID is required");

    auto existing = repo.findByName(req.environmentId, req.name);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Namespace '" ~ req.name ~ "' already exists");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    Namespace ns;
    ns.id = id;
    ns.environmentId = req.environmentId;
    ns.tenantId = req.tenantId;
    ns.name = req.name;
    ns.description = req.description;
    ns.status = NamespaceStatus.active;
    ns.cpuLimit = req.cpuLimit;
    ns.memoryLimit = req.memoryLimit;
    ns.cpuRequest = req.cpuRequest;
    ns.memoryRequest = req.memoryRequest;
    ns.podLimit = req.podLimit > 0 ? req.podLimit : 100;
    ns.quotaEnforcement = parseQuotaEnforcement(req.quotaEnforcement);
    ns.istioInjection = req.istioInjection;
    ns.labels = req.labels;
    ns.annotations = req.annotations;
    ns.createdBy = req.createdBy;
    ns.createdAt = clockSeconds();
    ns.modifiedAt = ns.createdAt;

    repo.save(ns);
    return CommandResult(true, id, "");
  }

  CommandResult updateNamespace(NamespaceId id, UpdateNamespaceRequest req)
  {
    auto ns = repo.findById(id);
    if (ns.id.length == 0)
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
    ns.modifiedAt = clockSeconds();

    repo.update(ns);
    return CommandResult(true, id, "");
  }

  Namespace getNamespace(NamespaceId id)
  {
    return repo.findById(id);
  }

  Namespace[] listByEnvironment(KymaEnvironmentId envId)
  {
    return repo.findByEnvironment(envId);
  }

  CommandResult deleteNamespace(NamespaceId id)
  {
    auto ns = repo.findById(id);
    if (ns.id.length == 0)
      return CommandResult(false, "", "Namespace not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private QuotaEnforcement parseQuotaEnforcement(string s)
  {
    switch (s)
    {
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

private long clockSeconds()
{
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 10_000_000;
}
