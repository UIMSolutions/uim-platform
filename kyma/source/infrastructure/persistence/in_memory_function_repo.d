module infrastructure.persistence.memory.function_repo;

import domain.types;
import domain.entities.serverless_function;
import domain.ports.function_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryFunctionRepository : FunctionRepository
{
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

    void save(ServerlessFunction fn) { store[fn.id] = fn; }
    void update(ServerlessFunction fn) { store[fn.id] = fn; }
    void remove(FunctionId id) { store.remove(id); }
}
