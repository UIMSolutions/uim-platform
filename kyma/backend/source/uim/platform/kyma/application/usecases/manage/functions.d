/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.functions;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Interactor: serverless functions. Every change triggers a rebuild.
class ManageFunctionsUseCase
  : ResourceUseCase!(ServerlessFunction, ServerlessFunctionId, CreateFunctionRequest, UpdateFunctionRequest),
  IManageFunctionsUseCase {
  protected FunctionValidator validator;

  this(KymaRepositories repos, IKymaEventPublisher publisher, IClusterGateway cluster, FunctionValidator validator) {
    super(repos, repos.functions, publisher, cluster, "Function", "kyma.function");
    this.validator = validator;
  }

  override protected ServerlessFunction build(CreateFunctionRequest r) {
    auto ns = requireNamespace(r.tenantId, r.parentId);
    requireModule(r.tenantId, ns.environmentId, WorkloadKind.function_);
    auto fn = ServerlessFunction(r.tenantId);
    fn.environmentId = ns.environmentId;
    fn.namespaceId = ns.id;
    fn.namespaceName = ns.name;
    assignMatching(fn, r.spec);
    fn.status = FunctionStatus.building;
    validator.validate(fn);
    ensureState(repos.functions.findByName(r.tenantId, ns.id, fn.name).isNull,
      "Function '" ~ fn.name ~ "' already exists in namespace '" ~ ns.name ~ "'");
    return fn;
  }

  override protected void apply(ref ServerlessFunction fn, FunctionSpec spec) {
    assignMatching(fn, spec, ["name"]);
    validator.validate(fn);
    fn.status = FunctionStatus.building;
  }

  override protected Json render(ServerlessFunction fn) {
    return toManifest(fn);
  }
}
