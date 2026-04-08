/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.log_stream;

// import uim.platform.logging.domain.entities.log_stream;
// import uim.platform.logging.domain.ports.repositories.log_streams;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class MemoryLogStreamRepository : LogStreamRepository {
  private LogStream[LogStreamId] store;

  LogStream findById(LogStreamId id) {
    if (auto p = id in store)
      return *p;
    return LogStream.init;
  }

  LogStream[] findByTenant(TenantId tenantId) {
    LogStream[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  LogStream findByName(TenantId tenantId, string name) {
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.name == name)
        return s;
    return LogStream.init;
  }

  void save(LogStream stream) {
    store[stream.id] = stream;
  }

  void update(LogStream stream) {
    store[stream.id] = stream;
  }

  void remove(LogStreamId id) {
    store.remove(id);
  }
}
