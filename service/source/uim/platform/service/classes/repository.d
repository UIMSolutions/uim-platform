/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.classes.repository;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class SAPRepository(T) {
  // Placeholder for repository methods
  // This class can be extended to implement specific data access logic for the service

  void save(T item) {
    // 
  }

  void update(T item) {
    // 
  }
}

class MemoryRepository(TEntity, TId) : IBaseRepository!(TEntity, TId) {
  private TEntity[TId][TenantId] store;

  bool existsTenant(TenantId tenantId) {
    return tenantId in store;
  }

  TEntity[] findByTenant(TenantId tenantId) {
    if (!existsTenant(tenantId))
      return null;

    return store[tenantId].byValue.array;
  }

  bool existsId(TId id, TenantId tenantId) {
    return (existsTenant(tenantId) && (id in store[tenantId]));
  }

  TEntity findById(TId id, TenantId tenantId) {
    if (!existsId(id, tenantId))
      return null;

    return store[tenantId][id];
  }

  void save(TEntity entity) {
    if (!existsTenant(entity.tenantId)) {
      TEntity[TId] entities;
      store[entity.tenantId] = entities;
    }
    store[entity.tenantId][entity.id] = entity;
  }

  void update(TEntity entity) {
    if (existsId(entity.id, entity.tenantId)) {
      store[entity.tenantId][entity.id] = entity;
    }
  }

  void remove(TId id, TenantId tenantId) {
    if (!existsId(id, tenantId))
      return;

    store[tenantId].remove(id);
    if (store[tenantId].empty) {
      store.remove(tenantId);
    }
  }
}
