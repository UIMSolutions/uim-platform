/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.function_repo;

import uim.platform.kyma.domain.types;
import uim.platform.kyma.domain.entities.serverless_function;
import uim.platform.kyma.domain.ports.repositories.functions;

// import std.algorithm : filter;
// import std.array : array;

class MemoryFunctionRepository : FunctionRepository {
  private ServerlessFunction[FunctionId] store;

  ServerlessFunction findById(FunctionId id)
  {
    if (auto p = id in store)
      return *p;
    return ServerlessFunction.init;
  }

  ServerlessFunction findByName(NamespaceId nsId, string name)
  {
    foreach (ref e; store.byValue())
      if (e.namespaceId == nsId && e.name == name)
        return e;
    return ServerlessFunction.init;
  }

  ServerlessFunction[] findByNamespace(NamespaceId nsId)
  {
    return store.byValue().filter!(e => e.namespaceId == nsId).array;
  }

  ServerlessFunction[] findByEnvironment(KymaEnvironmentId envId)
  {
    return store.byValue().filter!(e => e.environmentId == envId).array;
  }

  ServerlessFunction[] findByStatus(FunctionStatus status)
  {
    return store.byValue().filter!(e => e.status == status).array;
  }

  void save(ServerlessFunction fn)
  {
    store[fn.id] = fn;
  }

  void update(ServerlessFunction fn)
  {
    store[fn.id] = fn;
  }

  void remove(FunctionId id)
  {
    store.remove(id);
  }
}
