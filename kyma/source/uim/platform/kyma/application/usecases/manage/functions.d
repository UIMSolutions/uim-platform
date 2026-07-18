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

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for serverless function lifecycle management.
class ManageFunctionsUseCase { // TODO: UIMUseCase {
  protected FunctionRepository functionRepository;
  protected FunctionValidator validator;

  this(FunctionRepository functionRepository, FunctionValidator validator) {
    this.functionRepository = functionRepository;
    this.validator = validator;
  }

  CommandResult createFunction(CreateFunctionRequest request) {
    if (request.name.length == 0)
      return CommandResult(false, "", "Function name is required");
    if (request.namespaceId.isEmpty)
      return CommandResult(false, "", "Namespace ID is required");

    if (functionRepository.existsByName(request.namespaceId, request.name))
      return CommandResult(false, "",
          "Function '" ~ request.name ~ "' already exists in this namespace");

    auto serverlessFunction = ServerlessFunction(request.tenantId); //, request.createdBy);
    serverlessFunction.namespaceId = request.namespaceId;
    serverlessFunction.environmentId = request.environmentId;
    serverlessFunction.name = request.name;
    serverlessFunction.description = request.description;
    serverlessFunction.runtime = request.runtime.toRuntime();
    serverlessFunction.sourceCode = request.sourceCode;
    serverlessFunction.handler = request.handler;
    serverlessFunction.dependencies = request.dependencies;
    serverlessFunction.scalingType = request.scalingType.toScalingType;
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

    auto validationErr = validator.validate(serverlessFunction);
    if (validationErr.length > 0)
      return CommandResult(false, "", validationErr);

    functionRepository.save(serverlessFunction);
    return CommandResult(true, serverlessFunction.id.value, "");
  }

  CommandResult updateFunction(UpdateFunctionRequest req) {
    auto fn = functionRepository.findById(req.tenantId, req.functionId);
    if (fn.isNull)
      return CommandResult(false, "", "Function not found");

    if (req.description.length > 0)
      fn.description = req.description;
    if (req.sourceCode.length > 0)
      fn.sourceCode = req.sourceCode;
    if (req.handler.length > 0)
      fn.handler = req.handler;
    if (req.dependencies.length > 0)
      fn.dependencies = req.dependencies;
    if (req.scalingType.length > 0)
      fn.scalingType = req.scalingType.toScalingType();
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
    fn.updatedAt = clockSeconds();

    auto validationErr = validator.validate(fn);
    if (validationErr.length > 0)
      return CommandResult(false, "", validationErr);

    functionRepository.update(fn);
    return CommandResult(true, fn.id.value, "");
  }
  
  bool hasFunction(TenantId tenantId, ServerlessFunctionId functionId) {
    return functionRepository.existsById(tenantId, functionId);
  }
  
  ServerlessFunction getFunction(TenantId tenantId, ServerlessFunctionId functionId) {
    return functionRepository.findById(tenantId, functionId);
  }

  ServerlessFunction[] listByNamespace(TenantId tenantId, NamespaceId nsId) {
    return functionRepository.findByNamespace(tenantId, nsId);
  }

  ServerlessFunction[] listByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    return functionRepository.findByEnvironment(tenantId, environmentId);
  }

  CommandResult deleteFunction(TenantId tenantId, ServerlessFunctionId functionId) {
    auto fn = functionRepository.findById(tenantId, functionId);
    if (fn.isNull)
      return CommandResult(false, "", "Function not found");

    functionRepository.remove(fn);
    return CommandResult(true, fn.id.value, "");
  }
}


