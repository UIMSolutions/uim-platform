/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.data_controllers;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_controller;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying data controllers.
interface DataControllerRepository : ITenantRepository!(DataController, DataControllerId) {

  size_t countByCountry(TenantId tenantId, string country);
  DataController[] findByCountry(TenantId tenantId, string country);
  void removeByCountry(TenantId tenantId, string country);

}
