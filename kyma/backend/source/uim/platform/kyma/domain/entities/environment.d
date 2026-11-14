/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.environment;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// A Kyma runtime: a managed Gardener/Kubernetes cluster in a BTP subaccount.
/// Aggregate root of namespaces, modules and connected applications.
struct KymaEnvironment {
  mixin TenantEntity!KymaEnvironmentId;

  SubaccountId subaccountId;
  ClusterId clusterId;
  string name;
  string description;
  KymaPlan plan = KymaPlan.aws;
  string region;
  string kubernetesVersion;
  EnvironmentStatus status = EnvironmentStatus.provisioning;

  // Worker pool sizing
  string machineType;
  int autoScalerMin = 3;
  int autoScalerMax = 20;

  // OIDC configuration of the kube-apiserver
  string oidcIssuerUrl;
  string oidcClientId;
  string oidcGroupsClaim = "groups";
  string oidcUsernameClaim = "sub";

  // Networking (derived)
  string shootDomain;
  string kubeApiServerUrl;

  string[] administrators;
  /// Trial / free runtimes expire (0 = never).
  long expiresAt;

  /// Workloads can be reconciled only on a running (or updating) cluster.
  bool isOperational() const {
    return status == EnvironmentStatus.running || status == EnvironmentStatus.updating;
  }

  bool isExpired(long now) const {
    return expiresAt > 0 && now >= expiresAt;
  }
}
