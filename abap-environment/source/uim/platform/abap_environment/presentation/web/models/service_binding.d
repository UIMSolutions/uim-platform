/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.models.service_binding;

import uim.platform.abap_environment;

@safe:

class ServiceBindingViewModel {
  string id;
  string name;
  string description;
  string serviceType;
  TenantId tenantId;
  string systemInstanceId;
}
