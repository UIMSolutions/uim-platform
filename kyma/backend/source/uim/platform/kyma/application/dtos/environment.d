/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dtos.environment;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

struct EnvironmentSpec {
  SubaccountId subaccountId;
  string name;
  string description;
  KymaPlan plan = KymaPlan.aws;
  string region;
  string kubernetesVersion;
  string machineType;
  /// 0 = plan default
  int autoScalerMin;
  /// 0 = plan default
  int autoScalerMax;
  string oidcIssuerUrl;
  string oidcClientId;
  string oidcGroupsClaim = "groups";
  string oidcUsernameClaim = "sub";
  string[] administrators;
}

struct CreateEnvironmentRequest {
  TenantId tenantId;
  UserId actor;
  EnvironmentSpec spec;
}

alias UpdateEnvironmentRequest = UpdateRequest!(KymaEnvironmentId, EnvironmentSpec);
