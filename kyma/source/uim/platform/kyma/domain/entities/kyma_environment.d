/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.kyma_environment;

// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// A Kyma environment — a managed Kubernetes cluster with Kyma modules.
struct KymaEnvironment {
  mixin TenantEntity!(KymaEnvironmentId);

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

  long expiresAt;

  Json toJson() const {
    auto j = entityToJson
      .set("subaccountId", subaccountId.value)
      .set("clusterId", clusterId.value)
      .set("name", name)
      .set("description", description)
      .set("plan", plan.toString())
      .set("region", region)
      .set("kubernetesVersion", kubernetesVersion)
      .set("status", status.toString())
      .set("machineCount", machineCount)
      .set("machineType", machineType)
      .set("autoScalerMin", autoScalerMin)
      .set("autoScalerMax", autoScalerMax)
      .set("oidcIssuerUrl", oidcIssuerUrl)
      .set("oidcClientId", oidcClientId)
      .set("oidcGroupsClaim", oidcGroupsClaim.array)
      .set("oidcUsernameClaim", oidcUsernameClaim.array)
      .set("shootDomain", shootDomain)
      .set("kubeApiServerUrl", kubeApiServerUrl)
      .set("administrators", administrators.array)
      .set("expiresAt", expiresAt);

    return j;
  }
}
