/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.apps;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.app_registration;

interface AppRepository : ITenantRepository!(AppRegistration, AppId) {

  size_t countByStatus(AppStatus status, TenantId tenantId);
  AppRegistration[] findByStatus(AppStatus status, TenantId tenantId);
  void removeByStatus(AppStatus status, TenantId tenantId);

}
