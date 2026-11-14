/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dtos.namespace;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

struct NamespaceSpec {
  string name;
  string description;
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

alias CreateNamespaceRequest = CreateRequest!(KymaEnvironmentId, NamespaceSpec);
alias UpdateNamespaceRequest = UpdateRequest!(NamespaceId, NamespaceSpec);
