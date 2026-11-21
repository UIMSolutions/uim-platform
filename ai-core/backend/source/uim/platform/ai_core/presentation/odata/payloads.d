/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → request DTOs.
module uim.platform.ai_core.presentation.odata.payloads;

import uim.platform.ai_core;

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

bool has(Json p, string key) {
  return (key in p) !is null;
}

long longOf(Json p, string key, long fallback = 0) {
  if (key !in p)
    return fallback;
  auto v = p[key];
  if (v.type == Json.Type.int_)
    return v.get!long;
  if (v.type == Json.Type.float_)
    return cast(long) v.get!double;
  if (v.type == Json.Type.string) {
    try
      return v.get!string.strip.to!long;
    catch (Exception) {
    }
  }
  return fallback;
}

double doubleOf(Json p, string key, double fallback = 0) {
  if (key !in p)
    return fallback;
  auto v = p[key];
  if (v.type == Json.Type.float_)
    return v.get!double;
  if (v.type == Json.Type.int_)
    return cast(double) v.get!long;
  if (v.type == Json.Type.string) {
    try
      return v.get!string.strip.to!double;
    catch (Exception) {
    }
  }
  return fallback;
}

/// Array of strings (a single string is split at commas and new lines).
string[] textsOf(Json p, string key) @trusted {
  if (key !in p)
    return null;
  auto v = p[key];
  if (v.type == Json.Type.string)
    return v.get!string.splitter!(c => c == ',' || c == '\n').map!(s => s.strip.idup).filter!(s => s.length > 0).array;
  string[] values;
  if (v.type == Json.Type.array)
    foreach (item; v.get!(Json[]))
      if (item.type == Json.Type.string && item.get!string.strip.length > 0)
        values ~= item.get!string.strip;
  return values;
}

/// ISO timestamp (or null) → std time.
long timeOf(Json p, string key) {
  auto text = textOf(p, key);
  try
    return parseIsoTime(text);
  catch (Exception)
    throw AiCoreException.invalid("Property '" ~ key ~ "' is not an ISO 8601 timestamp");
}

Label[] labelsOf(Json p, string key) {
  return parseLabels(textsOf(p, key));
}

/// Composite OData key → (group, id); throws notFound for malformed keys.
void splitKey(string key, out ResourceGroupId rg, out string id, string what) {
  string g, i;
  if (!splitResourceKey(key, g, i))
    throw AiCoreException.notFound(what ~ " '" ~ key ~ "'");
  rg = ResourceGroupId(g);
  id = i;
}

// ── requests ────────────────────────────────────────────────────────────────

CreateResourceGroupRequest createResourceGroupRequest(const RequestContext ctx, Json p) {
  CreateResourceGroupRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.labels = labelsOf(p, "labels");
  return r;
}

CreateScenarioRequest createScenarioRequest(const RequestContext ctx, Json p) {
  CreateScenarioRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.resourceGroupId = ResourceGroupId(textOf(p, "resourceGroupId"));
  r.id = textOf(p, "id");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.labels = labelsOf(p, "labels");
  return r;
}

UpdateScenarioRequest updateScenarioRequest(const RequestContext ctx, string key, Json p) {
  UpdateScenarioRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  splitKey(key, r.resourceGroupId, r.id, "Scenario");
  if (has(p, "name"))
    r.name = textOf(p, "name");
  if (has(p, "description"))
    r.description = textOf(p, "description");
  if (has(p, "labels"))
    r.labels = labelsOf(p, "labels");
  return r;
}

private ParameterDef[] parametersOf(Json p) {
  return textsOf(p, "parameters").map!(t => parseParameter(t)).array;
}

private ArtifactSlot[] slotsOf(Json p, string key) {
  return textsOf(p, key).map!(t => parseSlot(t)).array;
}

CreateExecutableRequest createExecutableRequest(const RequestContext ctx, Json p) {
  CreateExecutableRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.resourceGroupId = ResourceGroupId(textOf(p, "resourceGroupId"));
  r.id = textOf(p, "id");
  r.scenarioId = textOf(p, "scenarioId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  if (has(p, "type"))
    r.type = textOf(p, "type");
  if (textOf(p, "versionId").length)
    r.versionId = textOf(p, "versionId");
  r.parameters = parametersOf(p);
  r.inputArtifacts = slotsOf(p, "inputArtifacts");
  r.outputArtifacts = slotsOf(p, "outputArtifacts");
  r.labels = labelsOf(p, "labels");
  return r;
}

UpdateExecutableRequest updateExecutableRequest(const RequestContext ctx, string key, Json p) {
  UpdateExecutableRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  splitKey(key, r.resourceGroupId, r.id, "Executable");
  if (has(p, "name"))
    r.name = textOf(p, "name");
  if (has(p, "description"))
    r.description = textOf(p, "description");
  if (has(p, "versionId"))
    r.versionId = textOf(p, "versionId");
  if (has(p, "parameters"))
    r.parameters = parametersOf(p);
  if (has(p, "inputArtifacts"))
    r.inputArtifacts = slotsOf(p, "inputArtifacts");
  if (has(p, "outputArtifacts"))
    r.outputArtifacts = slotsOf(p, "outputArtifacts");
  if (has(p, "labels"))
    r.labels = labelsOf(p, "labels");
  return r;
}

CreateConfigurationRequest createConfigurationRequest(const RequestContext ctx, Json p) {
  CreateConfigurationRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.resourceGroupId = ResourceGroupId(textOf(p, "resourceGroupId"));
  r.id = textOf(p, "id");
  r.name = textOf(p, "name");
  r.scenarioId = textOf(p, "scenarioId");
  r.executableId = textOf(p, "executableId");
  r.parameterBindings = labelsOf(p, "parameterBindings");
  r.inputArtifactBindings = textsOf(p, "inputArtifactBindings").map!(t => parseRef(t)).array;
  return r;
}

CreateArtifactRequest createArtifactRequest(const RequestContext ctx, Json p) {
  CreateArtifactRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.resourceGroupId = ResourceGroupId(textOf(p, "resourceGroupId"));
  r.id = textOf(p, "id");
  r.name = textOf(p, "name");
  if (has(p, "kind"))
    r.kind = textOf(p, "kind");
  r.url = textOf(p, "url");
  r.description = textOf(p, "description");
  r.scenarioId = textOf(p, "scenarioId");
  r.executionId = textOf(p, "executionId");
  r.labels = labelsOf(p, "labels");
  return r;
}

UpdateArtifactRequest updateArtifactRequest(const RequestContext ctx, string key, Json p) {
  UpdateArtifactRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  splitKey(key, r.resourceGroupId, r.id, "Artifact");
  if (has(p, "description"))
    r.description = textOf(p, "description");
  if (has(p, "labels"))
    r.labels = labelsOf(p, "labels");
  return r;
}

CreateScheduleRequest createScheduleRequest(const RequestContext ctx, Json p) {
  CreateScheduleRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.resourceGroupId = ResourceGroupId(textOf(p, "resourceGroupId"));
  r.id = textOf(p, "id");
  r.name = textOf(p, "name");
  r.configurationId = textOf(p, "configurationId");
  r.cron = textOf(p, "cron");
  if (textOf(p, "status").length)
    r.status = textOf(p, "status");
  r.startTime = timeOf(p, "startTime");
  r.endTime = timeOf(p, "endTime");
  return r;
}

UpdateScheduleRequest updateScheduleRequest(const RequestContext ctx, string key, Json p) {
  UpdateScheduleRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  splitKey(key, r.resourceGroupId, r.id, "Execution schedule");
  if (has(p, "name"))
    r.name = textOf(p, "name");
  if (has(p, "cron"))
    r.cron = textOf(p, "cron");
  if (has(p, "status"))
    r.status = textOf(p, "status");
  if (has(p, "startTime"))
    r.startTime = timeOf(p, "startTime");
  if (has(p, "endTime"))
    r.endTime = timeOf(p, "endTime");
  return r;
}

CreateDockerRegistrySecretRequest createDockerSecretRequest(const RequestContext ctx, Json p) {
  CreateDockerRegistrySecretRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.server = textOf(p, "server");
  r.username = textOf(p, "username");
  r.password = textOf(p, "password");
  return r;
}

UpdateDockerRegistrySecretRequest updateDockerSecretRequest(const RequestContext ctx, string key, Json p) {
  UpdateDockerRegistrySecretRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = key;
  if (has(p, "server"))
    r.server = textOf(p, "server");
  if (has(p, "username"))
    r.username = textOf(p, "username");
  if (textOf(p, "password").length)
    r.password = textOf(p, "password");
  return r;
}

CreateObjectStoreSecretRequest createObjectStoreSecretRequest(const RequestContext ctx, Json p) {
  CreateObjectStoreSecretRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.resourceGroupId = ResourceGroupId(textOf(p, "resourceGroupId"));
  r.id = textOf(p, "id");
  if (textOf(p, "type").length)
    r.type = textOf(p, "type");
  r.bucket = textOf(p, "bucket");
  r.endpoint = textOf(p, "endpoint");
  r.region = textOf(p, "region");
  r.pathPrefix = textOf(p, "pathPrefix");
  r.accessKeyId = textOf(p, "accessKeyId");
  r.secretAccessKey = textOf(p, "secretAccessKey");
  return r;
}

UpdateObjectStoreSecretRequest updateObjectStoreSecretRequest(const RequestContext ctx, string key, Json p) {
  UpdateObjectStoreSecretRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  splitKey(key, r.resourceGroupId, r.id, "Object store secret");
  foreach (name; ["bucket", "endpoint", "region", "pathPrefix"])
    if (has(p, name)) {
      auto v = textOf(p, name);
      switch (name) {
      case "bucket":
        r.bucket = v;
        break;
      case "endpoint":
        r.endpoint = v;
        break;
      case "region":
        r.region = v;
        break;
      default:
        r.pathPrefix = v;
      }
    }
  if (textOf(p, "secretAccessKey").length) {
    r.accessKeyId = textOf(p, "accessKeyId");
    r.secretAccessKey = textOf(p, "secretAccessKey");
  }
  return r;
}

///
unittest {
  auto p = Json(["labels": Json([Json("a=1"), Json("b=2")]), "parameters": Json("epochs=5, lr")]);
  assert(labelsOf(p, "labels") == [Label("a", "1"), Label("b", "2")]);
  assert(parametersOf(p).length == 2 && parametersOf(p)[1].required);
  ResourceGroupId rg;
  string id;
  splitKey("default~x", rg, id, "X");
  assert(rg.value == "default" && id == "x");
  assert(failsWith(AiCoreErrorKind.notFound, () { splitKey("x", rg, id, "X"); }));
  assert(longOf(Json(["n": Json("42")]), "n") == 42 && doubleOf(Json(["v": Json(2)]), "v") == 2.0);
}
