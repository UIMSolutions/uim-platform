/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.data_controllers;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_controller;
// import uim.platform.data.privacy.domain.ports.data_controller_repository;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryDataControllerRepository : TenantRepository!(DataController, DataControllerId), DataControllerRepository {

  size_t countByCountry(TenantId tenantId, string country) {
    return findByCountry(tenantId, country).length;
  }

  DataController[] filterByCountry(DataController[] controllers, string country) {
    return controllers.filter!(c => c.country == country).array;
  }

  DataController[] findByCountry(TenantId tenantId, string country) {
    return filterByCountry(findByTenant(tenantId), country);
  }

  void removeByCountry(TenantId tenantId, string country) {
    findByCountry(tenantId, country).each!(entity => remove(entity.id));
  }

}
