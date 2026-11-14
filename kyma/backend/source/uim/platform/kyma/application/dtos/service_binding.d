/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dtos.service_binding;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

struct ServiceBindingSpec {
  string name;
  string description;
  /// "" = binding name
  string secretName;
  string parametersJson;
  KeyValue[] labels;
}

alias CreateServiceBindingRequest = CreateRequest!(ServiceInstanceId, ServiceBindingSpec);
alias UpdateServiceBindingRequest = UpdateRequest!(ServiceBindingId, ServiceBindingSpec);
