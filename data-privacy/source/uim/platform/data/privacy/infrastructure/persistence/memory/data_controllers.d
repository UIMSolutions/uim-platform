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
class MemoryDataControllerRepository : DataControllerRepository {
  private DataController[] store;

  DataController[] findByTenant(TenantId tenantId) {
    DataController[] result;
    foreach (s; findAll)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  DataController* findById(DataControllerId tenantId, id tenantId) {
    foreach (s; findAll)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  DataController[] findByCountry(TenantId tenantId, string country) {
    DataController[] result;
    foreach (s; findByTenant(tenantId))
      if (s.country == country)
        result ~= s;
    return result;
  }

  void save(DataController entity) {
    store ~= entity;
  }

  void update(DataController entity) {
    foreach (s; findAll)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(DataControllerId tenantId, id tenantId) {
    DataController[] kept;
    foreach (s; findByTenant(tenantId))
      if (!(s.id == id))
        kept ~= s;
    store = kept;
  }
}
