/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.application.dto;
import uim.platform.private_link;

mixin(ShowModule!());

@safe:
// ── ServiceInstance DTOs ────────────────────────────────────────────────────

struct CreateServiceInstanceRequest {
  TenantId tenantId;
  string name;
  string description;
  string resourceId;
  string iaasProvider;
  string plan;
  string region;
  string subaccountId;
}

struct UpdateServiceInstanceRequest {
  TenantId tenantId;
  ServiceInstanceId instanceId;
  string description;
  string statusMessage;
}

// ── PrivateEndpoint DTOs ────────────────────────────────────────────────────

struct CreatePrivateEndpointRequest {
  TenantId tenantId;
  ServiceInstanceId serviceInstanceId;
  string name;
  string privateIpAddress;
  string hostname;
  ushort port;
  string iaasProvider;
  string region;
  string providerEndpointId;
}

struct ApprovePrivateEndpointRequest {
  TenantId tenantId;
  PrivateEndpointId endpointId;
  string providerEndpointId;
  string privateIpAddress;
  string hostname;
  ushort port;
}

struct UpdatePrivateEndpointStatusRequest {
  TenantId tenantId;
  PrivateEndpointId endpointId;
  string status;
  string statusMessage;
}

// ── ServiceBinding DTOs ─────────────────────────────────────────────────────

struct CreateServiceBindingRequest {
  TenantId tenantId;
  ServiceBindingId bindingId;
  ServiceInstanceId instanceId;
  string applicationId;
}

struct DeleteServiceBindingRequest {
  TenantId tenantId;
  ServiceBindingId bindingId;
}
