/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.services.environment_policy;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Limits and defaults of a Kyma plan.
struct PlanLimits {
  int minNodes;
  int maxNodes;
  string defaultMachineType;
  string defaultRegion;
  string[] regions; /// empty = any region
  int lifetimeDays; /// 0 = no expiry
}

/// The rules of each plan (modelled on SAP BTP Kyma runtime plans).
PlanLimits limitsOf(KymaPlan plan) pure {
  final switch (plan) {
  case KymaPlan.aws:
    return PlanLimits(3, 300, "m6i.large", "eu-central-1",
      ["eu-central-1", "eu-west-2", "us-east-1", "us-west-2", "ap-southeast-1", "ap-northeast-1", "ca-central-1", "sa-east-1"]);
  case KymaPlan.azure:
    return PlanLimits(3, 300, "Standard_D2s_v5", "westeurope",
      ["westeurope", "northeurope", "switzerlandnorth", "eastus", "westus2", "centralus", "japaneast", "australiaeast"]);
  case KymaPlan.gcp:
    return PlanLimits(3, 300, "n2-standard-2", "europe-west3",
      ["europe-west3", "europe-west4", "us-central1", "asia-south1", "me-central2"]);
  case KymaPlan.sapConvergedCloud:
    return PlanLimits(3, 40, "g_c2_m8", "eu-de-1", ["eu-de-1", "ap-sa-1", "ap-jp-1"]);
  case KymaPlan.trial:
    return PlanLimits(1, 1, "m6i.large", "eu-central-1", null, 14);
  case KymaPlan.free_:
    return PlanLimits(1, 1, "m6i.large", "eu-central-1", null, 30);
  }
}

/// Fill derived and defaulted values of a new environment.
void applyEnvironmentDefaults(ref KymaEnvironment env, long now) {
  auto limits = limitsOf(env.plan);
  if (env.region.length == 0)
    env.region = limits.defaultRegion;
  if (env.machineType.length == 0)
    env.machineType = limits.defaultMachineType;
  if (env.kubernetesVersion.length == 0)
    env.kubernetesVersion = "1.31";
  if (env.autoScalerMin <= 0 || limits.maxNodes == 1)
    env.autoScalerMin = limits.minNodes;
  if (env.autoScalerMax <= 0 || limits.maxNodes == 1)
    env.autoScalerMax = limits.maxNodes == 1 ? 1 : max(env.autoScalerMin, 20);
  if (env.clusterId.isNull)
    env.clusterId = ClusterId(env.id.value.length >= 7 ? "c-" ~ env.id.value[0 .. 7] : "c-" ~ env.name);
  env.shootDomain = env.clusterId.value ~ ".kyma.ondemand.com";
  env.kubeApiServerUrl = "https://api." ~ env.shootDomain;
  env.expiresAt = limits.lifetimeDays > 0 ? now + limits.lifetimeDays * stdTimeDay : 0;
}

/// Validate an environment against the rules of its plan.
void validateEnvironment(const ref KymaEnvironment env) {
  import std.algorithm : canFind;

  validateResourceName("Environment", env.name);
  auto limits = limitsOf(env.plan);
  validate(limits.regions.length == 0 || limits.regions.canFind(env.region),
    "Region '" ~ env.region ~ "' is not available for plan " ~ enumText(env.plan));
  validate(env.autoScalerMin >= limits.minNodes,
    "Plan " ~ enumText(env.plan) ~ " requires at least " ~ limits.minNodes.to!string ~ " nodes");
  validate(env.autoScalerMax <= limits.maxNodes,
    "Plan " ~ enumText(env.plan) ~ " allows at most " ~ limits.maxNodes.to!string ~ " nodes");
  validate(env.autoScalerMin <= env.autoScalerMax, "autoScalerMin must not exceed autoScalerMax");
  validate(env.oidcIssuerUrl.length == 0 || env.oidcIssuerUrl.startsWith("https://"),
    "OIDC issuer URL must use https");
}

///
unittest {
  auto env = KymaEnvironment(TenantId("t"));
  env.name = "dev";
  env.plan = KymaPlan.trial;
  applyEnvironmentDefaults(env, 1000);
  assert(env.autoScalerMin == 1 && env.autoScalerMax == 1);
  assert(env.expiresAt == 1000 + 14 * stdTimeDay);
  assert(env.kubeApiServerUrl.startsWith("https://api.c-"));
  validateEnvironment(env);

  env.plan = KymaPlan.azure;
  env.region = "eu-central-1";
  bool failed;
  try validateEnvironment(env);
  catch (KymaValidationException) failed = true;
  assert(failed);
}
