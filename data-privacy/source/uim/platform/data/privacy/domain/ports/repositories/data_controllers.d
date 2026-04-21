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
interface DataControllerRepository {
  bool existsByTenant(TenantId tenantId);
  DataController[] findByTenant(TenantId tenantId);
 
  bool existsById(DataControllerId tenantId, id tenantId);
  DataController findById(DataControllerId tenantId, id tenantId);

  DataController[] findByCountry(TenantId tenantId, string country);

  void save(DataController controller);
  void update(DataController controller);
  void remove(DataControllerId tenantId, id tenantId);
}
