/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.data_controller_repo;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.data_controller;
import uim.platform.data.privacy.domain.ports.data_controller_repository;

class MemoryDataControllerRepository : DataControllerRepository {
  private DataController[] store;

  DataController[] findByTenant(TenantId tenantId) {
    DataController[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  DataController* findById(DataControllerId id, TenantId tenantId) {
    foreach (ref s; store)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  DataController[] findByCountry(TenantId tenantId, string country) {
    DataController[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.country == country)
        result ~= s;
    return result;
  }

  void save(DataController entity) {
    store ~= entity;
  }

  void update(DataController entity) {
    foreach (ref s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(DataControllerId id, TenantId tenantId) {
    DataController[] kept;
    foreach (ref s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}
