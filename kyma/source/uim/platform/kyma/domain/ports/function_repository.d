module uim.platform.kyma.domain.ports.function_repository;

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
