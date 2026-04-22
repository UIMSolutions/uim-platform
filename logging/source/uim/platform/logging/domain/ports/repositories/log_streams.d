/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.repositories.log_streams;

// import uim.platform.logging.domain.entities.log_stream;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface LogStreamRepository : ITenantRepository!(LogStream, LogStreamId) {

  bool existsByName(TenantId tenantId, string name);
  LogStream findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

}
