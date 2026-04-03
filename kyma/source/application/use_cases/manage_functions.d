module application.usecases.manage_functions;

import uim.platform.xyz.application.dto;
import domain.entities.serverless_function;
import domain.ports.function_repository;
import domain.services.function_validator;
import domain.types;

/// Application service for serverless function lifecycle management.
class ManageFunctionsUseCase
{
    private FunctionRepository repo;
    private FunctionValidator validator;

    this(FunctionRepository repo, FunctionValidator validator)
    {
        this.repo = repo;
        this.validator = validator;
    }

    CommandResult create(CreateFunctionRequest req)
    {
        if (req.name.length == 0)
            return CommandResult(false, "", "Function name is required");
        if (req.namespaceId.length == 0)
            return CommandResult(false, "", "Namespace ID is required");

        auto existing = repo.findByName(req.namespaceId, req.name);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Function '" ~ req.name ~ "' already exists in this namespace");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        ServerlessFunction fn;
        fn.id = id;
        fn.namespaceId = req.namespaceId;
        fn.environmentId = req.environmentId;
        fn.tenantId = req.tenantId;
        fn.name = req.name;
        fn.description = req.description;
        fn.runtime = parseRuntime(req.runtime);
        fn.sourceCode = req.sourceCode;
        fn.handler = req.handler;
        fn.dependencies = req.dependencies;
        fn.scalingType = parseScalingType(req.scalingType);
        fn.minReplicas = req.minReplicas > 0 ? req.minReplicas : 1;
        fn.maxReplicas = req.maxReplicas > 0 ? req.maxReplicas : 5;
        fn.cpuRequest = req.cpuRequest;
        fn.cpuLimit = req.cpuLimit;
        fn.memoryRequest = req.memoryRequest;
        fn.memoryLimit = req.memoryLimit;
        fn.envVars = req.envVars;
        fn.labels = req.labels;
        fn.timeoutSeconds = req.timeoutSeconds > 0 ? req.timeoutSeconds : 180;
        fn.status = FunctionStatus.building;
        fn.createdBy = req.createdBy;
        fn.createdAt = clockSeconds();
        fn.modifiedAt = fn.createdAt;

        auto validationErr = validator.validate(fn);
        if (validationErr.length > 0)
            return CommandResult(false, "", validationErr);

        repo.save(fn);
        return CommandResult(true, id, "");
    }

    CommandResult updateFunction(FunctionId id, UpdateFunctionRequest req)
    {
        auto fn = repo.findById(id);
        if (fn.id.length == 0)
            return CommandResult(false, "", "Function not found");

        if (req.description.length > 0) fn.description = req.description;
        if (req.sourceCode.length > 0) fn.sourceCode = req.sourceCode;
        if (req.handler.length > 0) fn.handler = req.handler;
        if (req.dependencies.length > 0) fn.dependencies = req.dependencies;
        if (req.scalingType.length > 0) fn.scalingType = parseScalingType(req.scalingType);
        if (req.minReplicas > 0) fn.minReplicas = req.minReplicas;
        if (req.maxReplicas > 0) fn.maxReplicas = req.maxReplicas;
        if (req.cpuRequest.length > 0) fn.cpuRequest = req.cpuRequest;
        if (req.cpuLimit.length > 0) fn.cpuLimit = req.cpuLimit;
        if (req.memoryRequest.length > 0) fn.memoryRequest = req.memoryRequest;
        if (req.memoryLimit.length > 0) fn.memoryLimit = req.memoryLimit;
        if (req.envVars !is null) fn.envVars = req.envVars;
        if (req.labels !is null) fn.labels = req.labels;
        if (req.timeoutSeconds > 0) fn.timeoutSeconds = req.timeoutSeconds;
        fn.status = FunctionStatus.building;
        fn.modifiedAt = clockSeconds();

        auto validationErr = validator.validate(fn);
        if (validationErr.length > 0)
            return CommandResult(false, "", validationErr);

        repo.update(fn);
        return CommandResult(true, id, "");
    }

    ServerlessFunction getFunction(FunctionId id) { return repo.findById(id); }
    ServerlessFunction[] listByNamespace(NamespaceId nsId) { return repo.findByNamespace(nsId); }
    ServerlessFunction[] listByEnvironment(KymaEnvironmentId envId) { return repo.findByEnvironment(envId); }

    CommandResult deleteFunction(FunctionId id)
    {
        auto fn = repo.findById(id);
        if (fn.id.length == 0)
            return CommandResult(false, "", "Function not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }

    private FunctionRuntime parseRuntime(string s)
    {
        switch (s)
        {
            case "nodejs18": return FunctionRuntime.nodejs18;
            case "nodejs20": return FunctionRuntime.nodejs20;
            case "python39": return FunctionRuntime.python39;
            case "python312": return FunctionRuntime.python312;
            default: return FunctionRuntime.nodejs20;
        }
    }

    private ScalingType parseScalingType(string s)
    {
        switch (s)
        {
            case "fixed": return ScalingType.fixed;
            case "auto": return ScalingType.auto_;
            default: return ScalingType.auto_;
        }
    }
}

private long clockSeconds()
{
    import core.time : MonoTime;
    return MonoTime.currTime.ticks / 10_000_000;
}
