/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.infrastructure.repositories.repository;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class PlatformRepository(TEntity) : IPlatformRepository!(TEntity) {
  TEntity[] store;

  this() {
    initialize();
  }

  bool initialize(Json initData = Json(null)) {
    return true;
  }

  bool exists(TEntity entity) {
    return store.any!(e => e == entity);
  }

  size_t indexOf(TEntity entity) {
    return store.countUntil!(e => e == entity);
  }

  void save(TEntity entity) {
    if (exists(entity)) {
      store[store.indexOf(entity)] = entity;
    }
    else {
      store ~= entity;
    }
  }

  void remove(TEntity entity) {
    if (exists(entity)) {
      store.remove(indexOf(entity));
    }
  }

  void save(TEntity[] entities) {
    entities.each!(entity => save(entity));
  }

  void update(TEntity[] entities) {
    entities.each!(entity => update(entity));
  }

  void remove(TEntity[] entities) {
    entities.each!(entity => remove(entity));
  }

}

