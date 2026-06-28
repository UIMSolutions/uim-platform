/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.application.usecases.manage.private_endpoints;
import uim.platform.private_link;

// mixin(ShowModule!());

@safe:
/// Use case: manage private endpoint creation, approval and status transitions.
class ManagePrivateEndpointsUseCase {
  private PrivateEndpointRepository endpoints;
  private ServiceInstanceRepository instances;

  this(PrivateEndpointRepository endpoints, ServiceInstanceRepository instances) {
    this.endpoints = endpoints;
    this.instances = instances;
  }

  CommandResult createEndpoint(CreatePrivateEndpointRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Name is required");

    auto inst = instances.findById(req.tenantId, req.serviceInstanceId);
    if (inst.id.value.length == 0)
      return CommandResult(false, "", "Service instance not found");

    auto ep = PrivateEndpoint();
    ep.id = PrivateEndpointId(generateId());
    ep.tenantId = req.tenantId;
    ep.serviceInstanceId = req.serviceInstanceId;
    ep.name = req.name;
    ep.privateIpAddress = req.privateIpAddress;
    ep.hostname = req.hostname;
    ep.port = req.port;
    ep.providerEndpointId = req.providerEndpointId;
    ep.iaasProvider = toIaasProvider(req.iaasProvider);
    ep.region = req.region;
    ep.status = EndpointStatus.pendingAcceptance;
    ep.createdAt = currentTimeMs();
    ep.updatedAt = ep.createdAt;

    endpoints.save(ep);

    // Update parent instance status to provisioning
    auto updated = inst;
    updated.status = InstanceStatus.provisioning;
    updated.privateEndpointId = ep.id;
    updated.updatedAt = ep.createdAt;
    instances.update(updated);

    return CommandResult(true, ep.id.value, "Private endpoint created, awaiting acceptance");
  }

  CommandResult approveEndpoint(ApprovePrivateEndpointRequest req) {
    auto ep = endpoints.findById(req.tenantId, req.endpointId);
    if (ep.id.value.length == 0)
      return CommandResult(false, "", "Private endpoint not found");

    auto updated = ep;
    updated.status = EndpointStatus.approved;
    updated.providerEndpointId = req.providerEndpointId;
    updated.privateIpAddress = req.privateIpAddress;
    updated.hostname = req.hostname;
    updated.port = req.port;
    updated.approvedAt = currentTimeMs();
    updated.updatedAt = updated.approvedAt;

    endpoints.update(updated);

    // Transition instance to ready once endpoint is approved
    auto inst = instances.findById(req.tenantId, ep.serviceInstanceId);
    if (inst.id.value.length > 0) {
      auto instUp = inst;
      instUp.status = InstanceStatus.ready;
      instUp.updatedAt = updated.approvedAt;
      instances.update(instUp);
    }

    return CommandResult(true, ep.id.value, "Private endpoint approved");
  }

  CommandResult updateEndpointStatus(UpdatePrivateEndpointStatusRequest req) {
    auto ep = endpoints.findById(req.tenantId, req.endpointId);
    if (ep.id.value.length == 0)
      return CommandResult(false, "", "Private endpoint not found");

    auto updated = ep;
    updated.status = toEndpointStatus(req.status);
    updated.statusMessage = req.statusMessage;
    updated.updatedAt = currentTimeMs();

    endpoints.update(updated);
    return CommandResult(true, ep.id.value, "Endpoint status updated");
  }

  CommandResult deleteEndpoint(TenantId tenantId, PrivateEndpointId id) {
    auto ep = endpoints.findById(tenantId, id);
    if (ep.id.value.length == 0)
      return CommandResult(false, "", "Private endpoint not found");
    endpoints.remove(ep);
    return CommandResult(true, id.value, "Private endpoint deleted");
  }

  PrivateEndpoint getEndpoint(TenantId tenantId, PrivateEndpointId id) {
    return endpoints.findById(tenantId, id);
  }

  PrivateEndpoint[] listEndpoints(TenantId tenantId) {
    return endpoints.find(tenantId);
  }

  PrivateEndpoint[] listByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return endpoints.findByServiceInstance(tenantId, instanceId);
  }

  // ── helpers ─────────────────────────────────────────────────────────────────

  private IaasProvider toIaasProvider(string s) {
    switch (s) {
      case "aws": return IaasProvider.aws;
      case "gcp": return IaasProvider.gcp;
      default:    return IaasProvider.azure;
    }
  }

  private EndpointStatus toEndpointStatus(string s) {
    switch (s) {
      case "approved":          return EndpointStatus.approved;
      case "rejected":          return EndpointStatus.rejected;
      case "disconnected":      return EndpointStatus.disconnected;
      case "ready":             return EndpointStatus.ready;
      case "failed":            return EndpointStatus.failed;
      default:                  return EndpointStatus.pendingAcceptance;
    }
  }
}
