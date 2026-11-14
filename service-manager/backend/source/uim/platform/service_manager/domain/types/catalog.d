/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Value objects of an Open Service Broker catalog (GET /v2/catalog).
module uim.platform.service_manager.domain.types.catalog;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct CatalogPlanDef {
  string id; /// broker side plan id
  string name;
  string description;
  bool free = true;
  bool bindable = true;
  bool planUpdateable = true;
  int maxInstances; /// 0 = unlimited
  string schemas; /// JSON text
  string metadata; /// JSON text
}

struct CatalogServiceDef {
  string id; /// broker side service id
  string name;
  string description;
  bool bindable = true;
  bool instancesRetrievable;
  bool bindingsRetrievable;
  bool planUpdateable;
  string[] tags;
  string metadata; /// JSON text
  CatalogPlanDef[] plans;
}

struct BrokerCatalog {
  CatalogServiceDef[] services;
}
