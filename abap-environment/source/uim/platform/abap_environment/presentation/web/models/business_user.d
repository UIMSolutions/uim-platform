/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.web.models.business_user;

@safe:

class BusinessUserViewModel {
  string id;
  string userName;
  string firstName;
  string lastName;
  string email;
  TenantId tenantId;
  string systemInstanceId;
}
