/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.instances;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.instance;
// import uim.platform.hana.domain.ports.repositories.instances;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class MemoryInstanceRepository : TenantRepository!(Instance, DatabaseInstanceId), InstanceRepository {

  // TODO
  
}
