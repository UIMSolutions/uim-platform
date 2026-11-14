/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Persistence layer: repositories (driven port implementations) on top of
/// the IDocumentStore of uim-platform:service (memory or JSON file).
module uim.platform.service_manager.persistence;

public {
  import uim.platform.service_manager.persistence.records;
  import uim.platform.service_manager.persistence.mappers;
  import uim.platform.service_manager.persistence.repositories;
  import uim.platform.service_manager.persistence.storages;
}
