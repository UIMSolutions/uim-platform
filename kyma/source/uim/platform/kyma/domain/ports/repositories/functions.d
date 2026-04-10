/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.functions;

// import uim.platform.kyma.domain.entities.serverless_function;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Port: outgoing — serverless function persistence.
interface FunctionRepository {
  bool existsById(FunctionId functionId);
  ServerlessFunction findById(FunctionId functionId);
  
  bool existsByName(NamespaceId namespaceId, string name);
  ServerlessFunction findByName(NamespaceId namespaceId, string name);
  
  ServerlessFunction[] findByNamespace(NamespaceId namespaceId);
  ServerlessFunction[] findByEnvironment(KymaEnvironmentId environmentId);
  ServerlessFunction[] findByStatus(FunctionStatus status);
  void save(ServerlessFunction fn);
  void update(ServerlessFunction fn);
  void remove(FunctionId functionId);
}
