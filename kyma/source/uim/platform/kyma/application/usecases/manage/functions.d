/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.functions;

// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.serverless_function;
// import uim.platform.kyma.domain.ports.repositories.functions;
// import uim.platform.kyma.domain.services.function_validator;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for serverless function lifecycle management.
class ManageFunctionsUseCase : UIMUseCase {
  private FunctionRepository functionRepository;
  private FunctionValidator validator;

  this(FunctionRepository functionRepository, FunctionValidator validator) {
    this.functionRepository = functionRepository;
    this.validator = validator;
  }

  CommandResult create(CreateFunctionRequest request) {
    if (request.name.length == 0)
      return CommandResult(false, "", "Function name is required");
    if (request.namespaceId.isEmpty)
      return CommandResult(false, "", "Namespace ID is required");

    auto existing = functionRepository.findByName(request.namespaceId, request.name);
    if (!existing.namespaceId.isEmpty)
      return CommandResult(false, "",
          "Function '" ~ request.name ~ "' already exists in this namespace");

    // import std.uuid : randomUUID;
    auto id = randomUUID();

    ServerlessFunction serverlessFunction;
    serverlessFunction.functionId = id;
    serverlessFunction.namespaceId = request.namespaceId;
    serverlessFunction.environmentId = request.environmentId;
    serverlessFunction.tenantId = request.tenantId;
    serverlessFunction.name = request.name;
    serverlessFunction.description = request.description;
    serverlessFunction.runtime = parseRuntime(request.runtime);
    serverlessFunction.sourceCode = request.sourceCode;
    serverlessFunction.handler = request.handler;
    serverlessFunction.dependencies = request.dependencies;
    serverlessFunction.scalingType = parseScalingType(request.scalingType);
    serverlessFunction.minReplicas = request.minReplicas > 0 ? request.minReplicas : 1;
    serverlessFunction.maxReplicas = request.maxReplicas > 0 ? request.maxReplicas : 5;
    serverlessFunction.cpuRequest = request.cpuRequest;
    serverlessFunction.cpuLimit = request.cpuLimit;
    serverlessFunction.memoryRequest = request.memoryRequest;
    serverlessFunction.memoryLimit = request.memoryLimit;
    serverlessFunction.envVars = request.envVars;
    serverlessFunction.labels = request.labels;
    serverlessFunction.timeoutSeconds = request.timeoutSeconds > 0 ? request.timeoutSeconds : 180;
    serverlessFunction.status = FunctionStatus.building;
    serverlessFunction.createdBy = request.createdBy;
    serverlessFunction.createdAt = clockSeconds();
    serverlessFunction.modifiedAt = serverlessFunction.createdAt;     

    auto validationErr = validator.validate(serverlessFunction);
    if (validationErr.length > 0)
      return CommandResult(false, "", validationErr);

    functionRepository.save(serverlessFunction);
    return CommandResult(true, id.toString, "");
  }

  CommandResult updateFunction(FunctionId functionId, UpdateFunctionRequest req) {
    if (!functionRepository.existsById(functionId))
      return CommandResult(false, "", "Function not found");

    auto fn = functionRepository.findById(functionId);
    if (req.description.length > 0)
      fn.description = req.description;
    if (req.sourceCode.length > 0)
      fn.sourceCode = req.sourceCode;
    if (req.handler.length > 0)
      fn.handler = req.handler;
    if (req.dependencies.length > 0)
      fn.dependencies = req.dependencies;
    if (req.scalingType.length > 0)
      fn.scalingType = parseScalingType(req.scalingType);
    if (req.minReplicas > 0)
      fn.minReplicas = req.minReplicas;
    if (req.maxReplicas > 0)
      fn.maxReplicas = req.maxReplicas;
    if (req.cpuRequest.length > 0)
      fn.cpuRequest = req.cpuRequest;
    if (req.cpuLimit.length > 0)
      fn.cpuLimit = req.cpuLimit;
    if (req.memoryRequest.length > 0)
      fn.memoryRequest = req.memoryRequest;
    if (req.memoryLimit.length > 0)
      fn.memoryLimit = req.memoryLimit;
    if (req.envVars !is null)
      fn.envVars = req.envVars;
    if (req.labels !is null)
      fn.labels = req.labels;
    if (req.timeoutSeconds > 0)
      fn.timeoutSeconds = req.timeoutSeconds;
    fn.status = FunctionStatus.building;
    fn.modifiedAt = clockSeconds();

    auto validationErr = validator.validate(fn);
    if (validationErr.length > 0)
      return CommandResult(false, "", validationErr);

    functionRepository.update(fn);
    return CommandResult(true, functionId.toString(), "");
  }

  ServerlessFunction getFunction(FunctionId functionId) {
    return functionRepository.findById(functionId);
  }

  ServerlessFunction[] listByNamespace(NamespaceId nsId) {
    return functionRepository.findByNamespace(nsId);
  }

  ServerlessFunction[] listByEnvironment(KymaEnvironmentId environmentId) {
    return functionRepository.findByEnvironment(environmentId);
  }

  CommandResult deleteFunction(FunctionId functionId) {
    if (!functionRepository.existsById(functionId))
      return CommandResult(false, "", "Function not found");

    auto fn = functionRepository.findById(functionId);
    functionRepository.remove(functionId);
    return CommandResult(true, functionId.toString(), "");
  }

  private FunctionRuntime parseRuntime(string runtimeName) {
    switch (runtimeName) {
    case "nodejs18":
      return FunctionRuntime.nodejs18;
    case "nodejs20":
      return FunctionRuntime.nodejs20;
    case "python39":
      return FunctionRuntime.python39;
    case "python312":
      return FunctionRuntime.python312;
    default:
      return FunctionRuntime.nodejs20;
    }
  }

  private ScalingType parseScalingType(string scalingTypeName) {
    switch (scalingTypeName) {
    case "fixed":
      return ScalingType.fixed;
    case "auto":
      return ScalingType.auto_;
    default:
      return ScalingType.auto_;
    }
  }
}


