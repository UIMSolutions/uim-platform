/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.functions;

// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.domain.entities.serverless_function;
// import uim.platform.kyma.domain.ports.repositories.functions;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class MemoryFunctionRepository : FunctionRepository {
  private ServerlessFunction[ServerlessFunctionId] store;

  bool existsById(ServerlessFunctionId functionId) {
    return (functionId in store) ? true : false;
  }

  ServerlessFunction findById(ServerlessFunctionId functionId) {
    if (existsById(functionId))
      return store[functionId];
    return ServerlessFunction.init;
  }

  bool existsByName(NamespaceId namespaceId, string name) {
    return findByNamespace(namespaceId).any!(e => e.name == name);
  }

  ServerlessFunction findByName(NamespaceId namespaceId, string name) {
    foreach (e; findByNamespace(namespaceId))
      if (e.name == name)
        return e;
    return ServerlessFunction.init;
  }

  ServerlessFunction[] findByNamespace(NamespaceId namespaceId) {
    return findAll()r!(e => e.namespaceId == namespaceId).array;
  }

  ServerlessFunction[] findByEnvironment(KymaEnvironmentId environmentId) {
    return findAll()r!(e => e.environmentId == environmentId).array;
  }

  ServerlessFunction[] findByStatus(FunctionStatus status) {
    return findAll()r!(e => e.status == status).array;
  }

  void save(ServerlessFunction fn) {
    store[fn.id] = fn;
  }

  void update(ServerlessFunction fn) {
    store[fn.id] = fn;
  }

  void remove(ServerlessFunctionId functionId) {
    store.remove(functionId);
  }
}
