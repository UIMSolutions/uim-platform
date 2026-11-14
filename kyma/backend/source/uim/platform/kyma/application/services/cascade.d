/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Application service: Kubernetes-like cascading deletion. Deleting a
/// namespace removes its workloads, deleting a runtime removes everything in it.
module uim.platform.kyma.application.services.cascade;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

class CascadeDeleter {
  protected KymaRepositories repos;

  this(KymaRepositories repos) {
    this.repos = repos;
  }

  /// Remove all workloads of a namespace. Returns the number of removed resources.
  size_t clearNamespace(TenantId tenantId, NamespaceId namespaceId) {
    size_t n;
    n += drop(repos.serviceBindings, repos.serviceBindings.findByNamespace(tenantId, namespaceId));
    n += drop(repos.serviceInstances, repos.serviceInstances.findByNamespace(tenantId, namespaceId));
    n += drop(repos.functions, repos.functions.findByNamespace(tenantId, namespaceId));
    n += drop(repos.apiRules, repos.apiRules.findByNamespace(tenantId, namespaceId));
    n += drop(repos.subscriptions, repos.subscriptions.findByNamespace(tenantId, namespaceId));

    // applications lose the binding to the namespace
    auto ns = repos.namespaces.findById(tenantId, namespaceId);
    if (!ns.isNull)
      foreach (app; repos.applications.findByEnvironment(tenantId, ns.environmentId))
        if (app.boundNamespaces.canFind(ns.name)) {
          app.boundNamespaces = app.boundNamespaces.filter!(b => b != ns.name).array;
          repos.applications.update(app);
        }
    return n;
  }

  /// Remove all namespaces (with workloads), modules and applications of a runtime.
  size_t clearEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    size_t n;
    foreach (ns; repos.namespaces.findByEnvironment(tenantId, environmentId)) {
      n += clearNamespace(tenantId, ns.id);
      repos.namespaces.remove(ns);
      n++;
    }
    n += drop(repos.applications, repos.applications.findByEnvironment(tenantId, environmentId));
    n += drop(repos.modules, repos.modules.findByEnvironment(tenantId, environmentId));
    return n;
  }

  private static size_t drop(TRepo, TEntity)(TRepo repo, TEntity[] entities) {
    if (entities.length > 0)
      repo.remove(entities);
    return entities.length;
  }
}
