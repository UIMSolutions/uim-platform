/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → request DTOs.
module uim.platform.service_manager.presentation.odata.payloads;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

TenantId tenantOf(const RequestContext ctx) {
  return TenantId(ctx.tenantId);
}

UserId actorOf(const RequestContext ctx) {
  return UserId(ctx.actor);
}

string textOf(Json p, string key) {
  return key in p && p[key].type == Json.Type.string ? p[key].get!string : "";
}

bool boolOf(Json p, string key, bool fallback = false) {
  return key in p && p[key].type == Json.Type.bool_ ? p[key].get!bool : fallback;
}

int intOf(Json p, string key) {
  return key in p && p[key].type == Json.Type.int_ ? cast(int) p[key].get!long : 0;
}

string[] textsOf(Json p, string key) @trusted {
  string[] values;
  if (key in p && p[key].type == Json.Type.array)
    foreach (v; p[key])
      if (v.type == Json.Type.string)
        values ~= v.get!string;
  return values;
}

/// Present (incl. null → "") or unset.
Patch!string textPatch(Json p, string key) {
  Patch!string r;
  if (key in p)
    r = textOf(p, key);
  return r;
}

Patch!bool boolPatch(Json p, string key) {
  Patch!bool r;
  if (key in p && p[key].type == Json.Type.bool_)
    r = p[key].get!bool;
  return r;
}

Patch!int intPatch(Json p, string key) {
  Patch!int r;
  if (key in p)
    r = intOf(p, key);
  return r;
}

Patch!(string[]) textsPatch(Json p, string key) {
  Patch!(string[]) r;
  if (key in p)
    r = textsOf(p, key);
  return r;
}

// ── requests ────────────────────────────────────────────────────────────────

RegisterPlatformRequest registerPlatformRequest(const RequestContext ctx, Json p) {
  RegisterPlatformRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.type = textOf(p, "type");
  r.region = textOf(p, "region");
  r.subaccountId = textOf(p, "subaccountId");
  r.brokerUrl = textOf(p, "brokerUrl");
  r.credentials = textOf(p, "credentials");
  return r;
}

UpdatePlatformRequest updatePlatformRequest(const RequestContext ctx, string key, Json p) {
  UpdatePlatformRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = PlatformId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.type = textPatch(p, "type");
  r.status = textPatch(p, "status");
  r.region = textPatch(p, "region");
  r.subaccountId = textPatch(p, "subaccountId");
  r.brokerUrl = textPatch(p, "brokerUrl");
  r.credentials = textPatch(p, "credentials");
  return r;
}

RegisterServiceBrokerRequest registerBrokerRequest(const RequestContext ctx, Json p) {
  RegisterServiceBrokerRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.brokerUrl = textOf(p, "brokerUrl");
  r.credentials = textOf(p, "credentials");
  return r;
}

UpdateServiceBrokerRequest updateBrokerRequest(const RequestContext ctx, string key, Json p) {
  UpdateServiceBrokerRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = ServiceBrokerId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.brokerUrl = textPatch(p, "brokerUrl");
  r.credentials = textPatch(p, "credentials");
  r.status = textPatch(p, "status");
  return r;
}

CreateServiceOfferingRequest createOfferingRequest(const RequestContext ctx, Json p) {
  CreateServiceOfferingRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.brokerId = textOf(p, "brokerId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.catalogId = textOf(p, "catalogId");
  r.catalogName = textOf(p, "catalogName");
  r.category = textOf(p, "category");
  r.bindable = boolPatch(p, "bindable");
  r.instancesRetrievable = boolPatch(p, "instancesRetrievable");
  r.bindingsRetrievable = boolPatch(p, "bindingsRetrievable");
  r.planUpdateable = boolPatch(p, "planUpdateable");
  r.metadata = textOf(p, "metadata");
  r.tags = textsOf(p, "tags");
  return r;
}

UpdateServiceOfferingRequest updateOfferingRequest(const RequestContext ctx, string key, Json p) {
  UpdateServiceOfferingRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = ServiceOfferingId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.catalogName = textPatch(p, "catalogName");
  r.category = textPatch(p, "category");
  r.status = textPatch(p, "status");
  r.bindable = boolPatch(p, "bindable");
  r.instancesRetrievable = boolPatch(p, "instancesRetrievable");
  r.bindingsRetrievable = boolPatch(p, "bindingsRetrievable");
  r.planUpdateable = boolPatch(p, "planUpdateable");
  r.metadata = textPatch(p, "metadata");
  r.tags = textsPatch(p, "tags");
  return r;
}

CreateServicePlanRequest createPlanRequest(const RequestContext ctx, Json p) {
  CreateServicePlanRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.offeringId = textOf(p, "offeringId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.catalogId = textOf(p, "catalogId");
  r.catalogName = textOf(p, "catalogName");
  r.pricing = textOf(p, "pricing");
  r.bindable = boolPatch(p, "bindable");
  r.planUpdateable = boolPatch(p, "planUpdateable");
  r.maxInstances = intOf(p, "maxInstances");
  r.schemas = textOf(p, "schemas");
  r.metadata = textOf(p, "metadata");
  return r;
}

UpdateServicePlanRequest updatePlanRequest(const RequestContext ctx, string key, Json p) {
  UpdateServicePlanRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = ServicePlanId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.catalogName = textPatch(p, "catalogName");
  r.pricing = textPatch(p, "pricing");
  r.bindable = boolPatch(p, "bindable");
  r.planUpdateable = boolPatch(p, "planUpdateable");
  r.maxInstances = intPatch(p, "maxInstances");
  r.schemas = textPatch(p, "schemas");
  r.metadata = textPatch(p, "metadata");
  return r;
}

ProvisionServiceInstanceRequest provisionInstanceRequest(const RequestContext ctx, Json p) {
  ProvisionServiceInstanceRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.name = textOf(p, "name");
  r.planId = textOf(p, "planId");
  r.platformId = textOf(p, "platformId");
  r.context = textOf(p, "context");
  r.parameters = textOf(p, "parameters");
  r.shared_ = boolOf(p, "shared");
  return r;
}

UpdateServiceInstanceRequest updateInstanceRequest(const RequestContext ctx, string key, Json p) {
  UpdateServiceInstanceRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = ServiceInstanceId(key);
  r.name = textPatch(p, "name");
  r.planId = textPatch(p, "planId");
  r.parameters = textPatch(p, "parameters");
  r.context = textPatch(p, "context");
  r.shared_ = boolPatch(p, "shared");
  r.usable = boolPatch(p, "usable");
  return r;
}

CreateServiceBindingRequest createBindingRequest(const RequestContext ctx, Json p) {
  CreateServiceBindingRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.instanceId = textOf(p, "instanceId");
  r.name = textOf(p, "name");
  r.parameters = textOf(p, "parameters");
  r.bindResource = textOf(p, "bindResource");
  r.context = textOf(p, "context");
  r.credentials = textOf(p, "credentials");
  return r;
}

CreateLabelRequest createLabelRequest(const RequestContext ctx, Json p) {
  CreateLabelRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.resourceType = textOf(p, "resourceType");
  r.resourceId = textOf(p, "resourceId");
  r.key = textOf(p, "key");
  r.value = textOf(p, "value");
  return r;
}

UpdateLabelRequest updateLabelRequest(const RequestContext ctx, string key, Json p) {
  UpdateLabelRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = LabelId(key);
  r.value = textPatch(p, "value");
  return r;
}

CompleteOperationRequest completeOperationRequest(const RequestContext ctx, Json p) {
  CompleteOperationRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = OperationId(textOf(p, "operationId"));
  r.succeeded = boolOf(p, "succeeded", true);
  r.errorMessage = textOf(p, "errorMessage");
  return r;
}
