/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.functions;

import uim.platform.kyma.domain.entities.serverless_function;
import uim.platform.kyma.domain.types;

/// Port: outgoing — serverless function persistence.
interface FunctionRepository
{
  ServerlessFunction findById(FunctionId id);
  ServerlessFunction findByName(NamespaceId nsId, string name);
  ServerlessFunction[] findByNamespace(NamespaceId nsId);
  ServerlessFunction[] findByEnvironment(KymaEnvironmentId envId);
  ServerlessFunction[] findByStatus(FunctionStatus status);
  void save(ServerlessFunction fn);
  void update(ServerlessFunction fn);
  void remove(FunctionId id);
}
