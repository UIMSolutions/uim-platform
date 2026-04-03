/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.kyma_environment;

import uim.platform.kyma.domain.types;

/// A Kyma environment — a managed Kubernetes cluster with Kyma modules.
struct KymaEnvironment
{
  KymaEnvironmentId id;
  TenantId tenantId;
  SubaccountId subaccountId;
  ClusterId clusterId;
  string name;
  string description;
  KymaPlan plan = KymaPlan.azure;
  string region;
  string kubernetesVersion;
  EnvironmentStatus status = EnvironmentStatus.provisioning;

  // Cluster sizing
  int machineCount = 3;
  string machineType;
  int autoScalerMin = 3;
  int autoScalerMax = 20;

  // OIDC configuration
  string oidcIssuerUrl;
  string oidcClientId;
  string[] oidcGroupsClaim;
  string[] oidcUsernameClaim;

  // Networking
  string shootDomain;
  string kubeApiServerUrl;

  // Administrator list
  string[] administrators;

  // Metadata
  string createdBy;
  long createdAt;
  long modifiedAt;
  long expiresAt;
}
