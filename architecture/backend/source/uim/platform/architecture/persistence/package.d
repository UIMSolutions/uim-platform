/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Persistence layer: driven adapters of the repository ports over the
/// document store (records, mappers, repositories, store factory).
module uim.platform.architecture.persistence;

public {
  import uim.platform.architecture.persistence.records;
  import uim.platform.architecture.persistence.mappers;
  import uim.platform.architecture.persistence.repositories;
  import uim.platform.architecture.persistence.storages;
}
