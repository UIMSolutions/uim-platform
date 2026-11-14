/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dtos.service_instance;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

struct ServiceInstanceSpec {
  string name;
  string description;
  string serviceOfferingName;
  string servicePlanName;
  string externalName;
  string parametersJson;
  KeyValue[] labels;
}

alias CreateServiceInstanceRequest = CreateRequest!(NamespaceId, ServiceInstanceSpec);
alias UpdateServiceInstanceRequest = UpdateRequest!(ServiceInstanceId, ServiceInstanceSpec);
