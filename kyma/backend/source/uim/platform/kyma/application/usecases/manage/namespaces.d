/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.namespaces;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Interactor: namespaces. Names are unique per runtime; system namespaces are reserved.
class ManageNamespacesUseCase
  : ResourceUseCase!(KymaNamespace, NamespaceId, CreateNamespaceRequest, UpdateNamespaceRequest),
  IManageNamespacesUseCase {
  protected CascadeDeleter cascade;

  this(KymaRepositories repos, IKymaEventPublisher publisher, IClusterGateway cluster, CascadeDeleter cascade) {
    super(repos, repos.namespaces, publisher, cluster, "Namespace", "kyma.namespace");
    this.cascade = cascade;
  }

  override protected KymaNamespace build(CreateNamespaceRequest r) {
    auto env = requireEnvironment(r.tenantId, r.parentId);
    auto ns = KymaNamespace(r.tenantId);
    ns.environmentId = env.id;
    assignMatching(ns, r.spec);
    check(ns);
    validate(!isReservedNamespace(ns.name), "Namespace '" ~ ns.name ~ "' is reserved by Kyma");
    ensureState(repos.namespaces.findByName(r.tenantId, env.id, ns.name).isNull,
      "Namespace '" ~ ns.name ~ "' already exists in environment '" ~ env.name ~ "'");
    return ns;
  }

  override protected void apply(ref KymaNamespace ns, NamespaceSpec spec) {
    assignMatching(ns, spec, ["name"]);
    check(ns);
  }

  protected static void check(const ref KymaNamespace ns) {
    validateResourceName("Namespace", ns.name);
    validate(ns.podLimit >= 0, "podLimit must not be negative");
    validateResources("Namespace quota", ns.cpuRequest, ns.cpuLimit, ns.memoryRequest, ns.memoryLimit);
  }

  override protected Json render(KymaNamespace ns) {
    return toManifest(ns);
  }

  override protected void beforeRemove(KymaNamespace ns) {
    cascade.clearNamespace(ns.tenantId, ns.id);
  }
}
