/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.data_controllers;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.data_controller;

/// Port for persisting and querying data controllers.
interface DataControllerRepository {
  DataController[] findByTenant(TenantId tenantId);
  DataController* findById(DataControllerId id, TenantId tenantId);
  DataController[] findByCountry(TenantId tenantId, string country);
  void save(DataController controller);
  void update(DataController controller);
  void remove(DataControllerId id, TenantId tenantId);
}
