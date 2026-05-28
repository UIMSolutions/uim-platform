/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.models.software_component;

@safe:

class SoftwareComponentViewModel {
  string id;
  string name;
  string description;
  string version_;
  TenantId tenantId;
  string systemInstanceId;
}
