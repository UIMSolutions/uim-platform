/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// AI API v2 wire formats (SAP AI Core JSON shapes): entities → JSON,
/// JSON → request parts, "ttl" durations, docker config JSON.
module uim.platform.ai_core.presentation.http.formats;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// ISO time or null.
private Json at(long stdTime) {
  auto t = isoTimeText(stdTime);
  return t.length ? Json(t) : Json(null);
}

Json apiLabels(const Label[] labels, string keyName = "key") {
  auto a = Json.emptyArray;
  foreach (l; labels)
    a ~= Json([keyName: Json(l.key), "value": Json(l.value)]);
  return a;
}

/// [{key|name, value}] → labels (throws invalid on wrong shapes).
Label[] parseApiLabels(Json body, string field) @trusted {
  if (field !in body || body[field].type == Json.Type.null_)
    return null;
  if (body[field].type != Json.Type.array)
    throw AiCoreException.invalid("'" ~ field ~ "' must be an array of {key, value}");
  Label[] labels;
  foreach (item; body[field].get!(Json[])) {
    if (item.type != Json.Type.object)
      throw AiCoreException.invalid("'" ~ field ~ "' must be an array of {key, value}");
    auto key = str(item, "key").length ? str(item, "key") : str(item, "name");
    labels ~= Label(key, str(item, "value"));
  }
  return labels;
}

string str(Json j, string key) {
  if (key !in j)
    return "";
  auto v = j[key];
  if (v.type == Json.Type.string)
    return v.get!string;
  if (v.type == Json.Type.int_ || v.type == Json.Type.float_ || v.type == Json.Type.bool_)
    return v.toString;
  return "";
}

/// AI API ttl: "<n>m", "<n>h", "<n>d" (or seconds as number) → seconds; "" → 0.
long parseTtl(Json body) {
  if ("ttl" !in body || body["ttl"].type == Json.Type.null_)
    return 0;
  auto v = body["ttl"];
  if (v.type == Json.Type.int_)
    return v.get!long;
  if (v.type != Json.Type.string)
    throw AiCoreException.invalid("ttl must be a duration like \"30m\", \"12h\" or \"7d\"");
  auto t = v.get!string.strip;
  if (t.length < 2)
    throw AiCoreException.invalid("Invalid ttl '" ~ t ~ "'");
  long factor;
  switch (t[$ - 1]) {
  case 'm':
    factor = 60;
    break;
  case 'h':
    factor = 3600;
    break;
  case 'd':
    factor = 86_400;
    break;
  default:
    throw AiCoreException.invalid("Invalid ttl unit in '" ~ t ~ "' (use m, h or d)");
  }
  try
    return t[0 .. $ - 1].to!long * factor;
  catch (Exception)
    throw AiCoreException.invalid("Invalid ttl '" ~ t ~ "'");
}

/// seconds → "<n>m|h|d" (largest exact unit), "" for 0.
string ttlText(long seconds) {
  if (seconds <= 0)
    return "";
  if (seconds % 86_400 == 0)
    return (seconds / 86_400).to!string ~ "d";
  if (seconds % 3600 == 0)
    return (seconds / 3600).to!string ~ "h";
  return (seconds / 60).to!string ~ "m";
}

// ── entities ────────────────────────────────────────────────────────────────

Json apiResourceGroup(const ResourceGroup g) {
  auto j = Json.emptyObject;
  j["resourceGroupId"] = g.id.value;
  j["tenantId"] = g.tenantId.value;
  j["zoneId"] = g.tenantId.value;
  j["labels"] = apiLabels(g.labels);
  j["status"] = cast(string) g.status;
  j["statusMessage"] = g.statusMessage;
  j["createdAt"] = at(g.createdAt);
  return j;
}

Json apiScenario(const Scenario s) {
  auto j = Json.emptyObject;
  j["id"] = s.id.value;
  j["name"] = s.name;
  j["description"] = s.description;
  j["labels"] = apiLabels(s.labels);
  j["createdAt"] = at(s.createdAt);
  j["modifiedAt"] = at(s.updatedAt);
  return j;
}

Json apiExecutable(const Executable e) {
  auto j = Json.emptyObject;
  j["id"] = e.id.value;
  j["name"] = e.name;
  j["description"] = e.description;
  j["scenarioId"] = e.scenarioId.value;
  j["versionId"] = e.versionId;
  j["deployable"] = e.deployable;
  auto params = Json.emptyArray;
  foreach (p; e.parameters)
    params ~= Json([
      "name": Json(p.key), "type": Json(p.type), "default": Json(p.defaultValue), "description": Json(p.description)
    ]);
  j["parameters"] = params;
  j["inputArtifacts"] = apiSlots(e.inputArtifacts);
  j["outputArtifacts"] = apiSlots(e.outputArtifacts);
  j["labels"] = apiLabels(e.labels);
  j["createdAt"] = at(e.createdAt);
  j["modifiedAt"] = at(e.updatedAt);
  return j;
}

private Json apiSlots(const ArtifactSlot[] slots) {
  auto a = Json.emptyArray;
  foreach (s; slots)
    a ~= Json(["name": Json(s.key), "kind": Json(cast(string) s.kind), "description": Json(s.description)]);
  return a;
}

ParameterDef[] parseApiParameters(Json body) @trusted {
  ParameterDef[] result;
  if ("parameters" in body && body["parameters"].type == Json.Type.array)
    foreach (p; body["parameters"].get!(Json[])) {
      auto type = str(p, "type");
      result ~= ParameterDef(str(p, "name").length ? str(p, "name") : str(p, "key"), type.length ? type : "string",
        str(p, "default"), str(p, "description"));
    }
  return result;
}

ArtifactSlot[] parseApiSlots(Json body, string field) @trusted {
  ArtifactSlot[] result;
  if (field in body && body[field].type == Json.Type.array)
    foreach (s; body[field].get!(Json[]))
      result ~= ArtifactSlot(str(s, "name").length ? str(s, "name") : str(s, "key"),
        parseDomainEnumOr!ArtifactKind(str(s, "kind"), ArtifactKind.other, "artifact kind"), str(s, "description"));
  return result;
}

Json apiConfiguration(const Configuration c) {
  auto j = Json.emptyObject;
  j["id"] = c.id.value;
  j["name"] = c.name;
  j["scenarioId"] = c.scenarioId.value;
  j["executableId"] = c.executableId.value;
  j["parameterBindings"] = apiLabels(c.parameterBindings);
  auto refs = Json.emptyArray;
  foreach (r; c.inputArtifactBindings)
    refs ~= Json(["key": Json(r.key), "artifactId": Json(r.artifactId.value)]);
  j["inputArtifactBindings"] = refs;
  j["createdAt"] = at(c.createdAt);
  return j;
}

ArtifactRef[] parseApiRefs(Json body, string field) @trusted {
  ArtifactRef[] result;
  if (field in body && body[field].type == Json.Type.array)
    foreach (r; body[field].get!(Json[]))
      result ~= ArtifactRef(str(r, "key"), ArtifactId(str(r, "artifactId")));
  return result;
}

/// artifacts: lookup of output artifacts (by id) for the embedded representation.
Json apiExecution(const Execution e, string configurationName, scope Artifact delegate(ArtifactId) @safe artifacts) {
  auto j = Json.emptyObject;
  j["id"] = e.id.value;
  j["configurationId"] = e.configurationId.value;
  j["configurationName"] = configurationName;
  j["scenarioId"] = e.scenarioId.value;
  j["executableId"] = e.executableId.value;
  j["executionScheduleId"] = e.scheduleId.isNull ? Json(null) : Json(e.scheduleId.value);
  j["status"] = cast(string) e.status;
  j["targetStatus"] = cast(string) e.targetStatus;
  j["statusMessage"] = e.statusMessage;
  auto outputs = Json.emptyArray;
  foreach (r; e.outputArtifacts) {
    auto a = artifacts(r.artifactId);
    outputs ~= a.isNull ? Json(["id": Json(r.artifactId.value), "name": Json(r.key)]) : apiArtifact(a);
  }
  j["outputArtifacts"] = outputs;
  j["tags"] = apiLabels(e.tags, "name");
  j["submissionTime"] = at(e.submissionTime);
  j["startTime"] = at(e.startTime);
  j["completionTime"] = at(e.completionTime);
  j["createdAt"] = at(e.createdAt);
  j["modifiedAt"] = at(e.updatedAt);
  return j;
}

Json apiDeployment(const Deployment d, string configurationName) {
  auto j = Json.emptyObject;
  j["id"] = d.id.value;
  j["deploymentUrl"] = d.deploymentUrl;
  j["configurationId"] = d.configurationId.value;
  j["configurationName"] = configurationName;
  j["latestRunningConfigurationId"] = d.latestRunningConfigurationId.isNull ? Json(null) : Json(d.latestRunningConfigurationId.value);
  j["scenarioId"] = d.scenarioId.value;
  j["executableId"] = d.executableId.value;
  j["status"] = cast(string) d.status;
  j["targetStatus"] = cast(string) d.targetStatus;
  j["lastOperation"] = cast(string) d.lastOperation;
  j["statusMessage"] = d.statusMessage;
  auto ttl = ttlText(d.ttlSeconds);
  j["ttl"] = ttl.length ? Json(ttl) : Json(null);
  j["submissionTime"] = at(d.submissionTime);
  j["startTime"] = at(d.startTime);
  j["completionTime"] = at(d.completionTime);
  j["createdAt"] = at(d.createdAt);
  j["modifiedAt"] = at(d.updatedAt);
  return j;
}

Json apiArtifact(const Artifact a) {
  auto j = Json.emptyObject;
  j["id"] = a.id.value;
  j["name"] = a.name;
  j["kind"] = cast(string) a.kind;
  j["url"] = a.url;
  j["description"] = a.description;
  j["scenarioId"] = a.scenarioId.value;
  j["executionId"] = a.executionId.isNull ? Json(null) : Json(a.executionId.value);
  j["labels"] = apiLabels(a.labels);
  j["createdAt"] = at(a.createdAt);
  j["modifiedAt"] = at(a.updatedAt);
  return j;
}

Json apiSchedule(const ExecutionSchedule s) {
  auto j = Json.emptyObject;
  j["id"] = s.id.value;
  j["name"] = s.name;
  j["configurationId"] = s.configurationId.value;
  j["cron"] = s.cron;
  j["start"] = at(s.startTime);
  j["end"] = at(s.endTime);
  j["status"] = cast(string) s.status;
  j["nextRunAt"] = at(s.nextRunAt);
  j["lastRunAt"] = at(s.lastRunAt);
  j["createdAt"] = at(s.createdAt);
  j["modifiedAt"] = at(s.updatedAt);
  return j;
}

/// The metric resource of one execution: values, tags and (empty) custom info.
Json apiMetricResource(string executionId, const Metric[] values, const Label[] tags) {
  auto metrics = Json.emptyArray;
  foreach (m; values)
    metrics ~= Json([
      "name": Json(m.name), "value": Json(m.value), "timestamp": at(m.timestamp), "step": Json(m.step),
      "labels": apiLabels(m.labels, "name")
    ]);
  auto j = Json.emptyObject;
  j["executionId"] = executionId;
  j["metrics"] = metrics;
  j["tags"] = apiLabels(tags, "name");
  j["customInfo"] = Json.emptyArray;
  return j;
}

MetricInput[] parseApiMetrics(Json body) @trusted {
  MetricInput[] result;
  if ("metrics" !in body)
    return result;
  if (body["metrics"].type != Json.Type.array)
    throw AiCoreException.invalid("'metrics' must be an array");
  foreach (m; body["metrics"].get!(Json[])) {
    MetricInput input;
    input.name = str(m, "name");
    auto v = "value" in m ? m["value"] : Json(null);
    if (v.type == Json.Type.float_)
      input.value = v.get!double;
    else if (v.type == Json.Type.int_)
      input.value = cast(double) v.get!long;
    else
      throw AiCoreException.invalid("Metric '" ~ input.name ~ "' needs a numeric value");
    input.step = "step" in m && m["step"].type == Json.Type.int_ ? m["step"].get!long : 0;
    auto ts = str(m, "timestamp");
    try
      input.timestamp = parseIsoTime(ts);
    catch (Exception)
      throw AiCoreException.invalid("Metric '" ~ input.name ~ "' has an invalid timestamp");
    input.labels = parseApiLabels(m, "labels");
    result ~= input;
  }
  return result;
}

Json apiDockerSecret(const DockerRegistrySecret s) {
  auto j = Json.emptyObject;
  j["name"] = s.id.value;
  j["server"] = s.server;
  j["username"] = s.username;
  j["createdAt"] = at(s.createdAt);
  j["modifiedAt"] = at(s.updatedAt);
  return j;
}

/// {"auths": {"<server>": {"username": "...", "password": "..."}}} → (server, user, password).
void parseDockerConfig(string text, out string server, out string username, out string password) @trusted {
  Json j;
  try
    j = parseJsonString(text);
  catch (Exception)
    throw AiCoreException.invalid(".dockerconfigjson is not valid JSON");
  if ("auths" !in j || j["auths"].type != Json.Type.object || j["auths"].length == 0)
    throw AiCoreException.invalid(".dockerconfigjson must contain an 'auths' object");
  foreach (string host, Json auth; j["auths"]) {
    server = host;
    username = str(auth, "username");
    password = str(auth, "password");
    if (password.length == 0)
      password = str(auth, "auth");
    break;
  }
}

Json apiObjectStoreSecret(const ObjectStoreSecret s) {
  auto j = Json.emptyObject;
  j["name"] = s.id.value;
  j["type"] = cast(string) s.type;
  j["bucket"] = s.bucket;
  j["endpoint"] = s.endpoint;
  j["region"] = s.region;
  j["pathPrefix"] = s.pathPrefix;
  j["metadata"] = Json(["hasCredentials": Json(s.hasCredentials)]);
  j["createdAt"] = at(s.createdAt);
  j["modifiedAt"] = at(s.updatedAt);
  return j;
}

/// AI API capabilities (GET /lm/meta).
Json aiApiMeta(string serviceVersion) {
  auto caps = Json.emptyObject;
  caps["logs"] = Json(["executions": Json(false), "deployments": Json(false)]);
  caps["multitenant"] = true;
  caps["shareable"] = true;
  caps["staticDeployments"] = false;
  caps["userDeployments"] = true;
  caps["userExecutions"] = true;
  caps["timeToLiveDeployments"] = true;
  caps["executionSchedules"] = true;
  caps["bulkUpdates"] = Json(["executions": Json(true), "deployments": Json(true)]);

  auto limits = Json.emptyObject;
  limits["executions"] = Json(["maxRunningCount": Json(-1)]);
  limits["deployments"] = Json(["maxRunningCount": Json(-1)]);
  limits["minimumFrequencyHour"] = 0;
  limits["timeToLiveDeployments"] = Json(["minimum": Json("10m"), "maximum": Json("365d")]);

  auto aiApi = Json.emptyObject;
  aiApi["version"] = "2.33.0";
  aiApi["capabilities"] = caps;
  aiApi["limits"] = limits;

  auto ext = Json.emptyObject;
  ext["metrics"] = Json(["version": Json("1.0.0"), "capabilities": Json(["extendedResults": Json(false)])]);
  ext["resourceGroups"] = Json(["version": Json("1.0.0")]);
  ext["dockerRegistrySecrets"] = Json(["version": Json("1.0.0")]);
  ext["objectStoreSecrets"] = Json(["version": Json("1.0.0")]);

  auto j = Json.emptyObject;
  j["runtimeIdentifier"] = "uim-ai-core";
  j["runtimeApiVersion"] = serviceVersion;
  j["description"] = "UIM AI Core (SAP AI Core style ML lifecycle runtime)";
  j["aiApi"] = aiApi;
  j["extensions"] = ext;
  return j;
}

///
unittest {
  assert(parseTtl(Json(["ttl": Json("30m")])) == 1800);
  assert(parseTtl(Json(["ttl": Json("2d")])) == 172_800);
  assert(parseTtl(Json.emptyObject) == 0);
  assert(failsWith(AiCoreErrorKind.invalid, () { parseTtl(Json(["ttl": Json("5w")])); }));
  assert(ttlText(7200) == "2h" && ttlText(600) == "10m" && ttlText(0) == "");
  string s, u, p;
  parseDockerConfig(`{"auths":{"docker.io":{"username":"bot","password":"pw"}}}`, s, u, p);
  assert(s == "docker.io" && u == "bot" && p == "pw");
  assert(parseApiLabels(Json(["labels": Json([Json(["key": Json("a"), "value": Json("1")])])]), "labels") == [Label("a", "1")]);
  auto m = parseApiMetrics(Json(["metrics": Json([Json(["name": Json("loss"), "value": Json(0.5), "step": Json(2)])])]));
  assert(m.length == 1 && m[0].value == 0.5 && m[0].step == 2);
}
