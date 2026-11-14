/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.service_bindings;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Interactor: service bindings. Keeps the binding count of the instance.
class ManageServiceBindingsUseCase
  : ResourceUseCase!(ServiceBinding, ServiceBindingId, CreateServiceBindingRequest, UpdateServiceBindingRequest),
  IManageServiceBindingsUseCase {

  this(KymaRepositories repos, IKymaEventPublisher publisher, IClusterGateway cluster) {
    super(repos, repos.serviceBindings, publisher, cluster, "Service binding", "kyma.servicebinding");
  }

  override protected ServiceBinding build(CreateServiceBindingRequest r) {
    validate(!r.parentId.isEmpty, "serviceInstanceId is required");
    auto si = repos.serviceInstances.findById(r.tenantId, r.parentId);
    if (si.isNull)
      throw new KymaNotFoundException("Service instance '" ~ r.parentId.value ~ "' not found");
    ensureState(si.status != ServiceInstanceStatus.failed, "Service instance '" ~ si.name ~ "' has failed");

    auto sb = ServiceBinding(r.tenantId);
    sb.environmentId = si.environmentId;
    sb.namespaceId = si.namespaceId;
    sb.namespaceName = si.namespaceName;
    sb.serviceInstanceId = si.id;
    sb.serviceInstanceName = si.name;
    assignMatching(sb, r.spec);
    check(sb);
    ensureState(repos.serviceBindings.findByName(r.tenantId, si.namespaceId, sb.name).isNull,
      "Service binding '" ~ sb.name ~ "' already exists in namespace '" ~ si.namespaceName ~ "'");
    sb.status = ServiceBindingStatus.creating;

    si.bindingCount++;
    repos.serviceInstances.update(si);
    return sb;
  }

  override protected void apply(ref ServiceBinding sb, ServiceBindingSpec spec) {
    // secret and name are fixed once the secret exists
    assignMatching(sb, spec, ["name", "secretName"]);
    check(sb);
  }

  protected static void check(ref ServiceBinding sb) {
    validateResourceName("Service binding", sb.name);
    if (sb.secretName.length == 0)
      sb.secretName = sb.name;
    validate(isDnsName(sb.secretName), "Secret name '" ~ sb.secretName ~ "' is not a valid DNS name");
    validateJsonObject("parametersJson", sb.parametersJson);
  }

  override protected void beforeRemove(ServiceBinding sb) {
    auto si = repos.serviceInstances.findById(sb.tenantId, sb.serviceInstanceId);
    if (!si.isNull && si.bindingCount > 0) {
      si.bindingCount--;
      repos.serviceInstances.update(si);
    }
  }

  override protected Json render(ServiceBinding sb) {
    return toManifest(sb);
  }
}
