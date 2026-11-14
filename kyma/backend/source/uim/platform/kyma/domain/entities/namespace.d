/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.namespace;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// A Kubernetes namespace inside a Kyma runtime. Scopes all workloads.
struct KymaNamespace {
  mixin TenantEntity!NamespaceId;

  KymaEnvironmentId environmentId;
  string name;
  string description;
  NamespaceStatus status = NamespaceStatus.active;

  // Resource quota
  string cpuRequest;
  string cpuLimit;
  string memoryRequest;
  string memoryLimit;
  int podLimit;
  QuotaEnforcement quotaEnforcement = QuotaEnforcement.enforce;

  bool istioInjection = true;
  KeyValue[] labels;
  KeyValue[] annotations;
}
