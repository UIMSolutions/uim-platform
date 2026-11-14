/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.service_instances;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Interactor: BTP service instances. Instances with bindings cannot be deleted.
class ManageServiceInstancesUseCase
  : ResourceUseCase!(ServiceInstance, ServiceInstanceId, CreateServiceInstanceRequest, UpdateServiceInstanceRequest),
  IManageServiceInstancesUseCase {

  this(KymaRepositories repos, IKymaEventPublisher publisher, IClusterGateway cluster) {
    super(repos, repos.serviceInstances, publisher, cluster, "Service instance", "kyma.serviceinstance");
  }

  override protected ServiceInstance build(CreateServiceInstanceRequest r) {
    auto ns = requireNamespace(r.tenantId, r.parentId);
    requireModule(r.tenantId, ns.environmentId, WorkloadKind.serviceInstance);
    auto si = ServiceInstance(r.tenantId);
    si.environmentId = ns.environmentId;
    si.namespaceId = ns.id;
    si.namespaceName = ns.name;
    assignMatching(si, r.spec);
    if (si.externalName.length == 0)
      si.externalName = si.name;
    check(si);
    ensureState(repos.serviceInstances.findByName(r.tenantId, ns.id, si.name).isNull,
      "Service instance '" ~ si.name ~ "' already exists in namespace '" ~ ns.name ~ "'");
    si.status = ServiceInstanceStatus.creating;
    return si;
  }

  override protected void apply(ref ServiceInstance si, ServiceInstanceSpec spec) {
    auto previousPlan = si.servicePlanName;
    // the offering of an instance is fixed; a plan change is an update of the instance
    assignMatching(si, spec, ["name", "serviceOfferingName"]);
    check(si);
    if (si.status == ServiceInstanceStatus.ready || previousPlan != si.servicePlanName)
      si.status = ServiceInstanceStatus.updating;
  }

  protected static void check(const ref ServiceInstance si) {
    validateResourceName("Service instance", si.name);
    validate(si.serviceOfferingName.length > 0, "serviceOfferingName is required (e.g. xsuaa, destination)");
    validate(si.servicePlanName.length > 0, "servicePlanName is required (e.g. application, lite)");
    validateJsonObject("parametersJson", si.parametersJson);
  }

  override protected void beforeRemove(ServiceInstance si) {
    auto bindings = repos.serviceBindings.findByServiceInstance(si.tenantId, si.id);
    ensureState(bindings.length == 0, "Service instance '" ~ si.name ~ "' still has "
        ~ bindings.length.to!string ~ " binding(s) — delete them first");
  }

  override protected Json render(ServiceInstance si) {
    return toManifest(si);
  }
}
