/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// AI API v2 (SAP AI Core compatible) under <root> (default /api/v2):
///
///   GET          /lm/meta
///   GET POST     /lm/scenarios                     GET PATCH DELETE /lm/scenarios/{id}
///   GET          /lm/scenarios/{id}/versions
///   GET POST     /lm/scenarios/{id}/executables    GET PATCH DELETE /lm/scenarios/{id}/executables/{executableId}
///   GET          /lm/executables
///   GET POST     /lm/configurations                GET DELETE       /lm/configurations/{id}
///   GET POST PATCH /lm/executions  (PATCH = bulk)  GET PATCH DELETE /lm/executions/{id}
///   GET POST PATCH /lm/deployments (PATCH = bulk)  GET PATCH DELETE /lm/deployments/{id}
///   GET POST     /lm/artifacts                     GET DELETE       /lm/artifacts/{id}
///   GET POST     /lm/executionSchedules            GET PATCH DELETE /lm/executionSchedules/{id}
///   GET PATCH DELETE /lm/metrics
///   GET          /lm/{configurations|executions|deployments|artifacts|executionSchedules}/$count
///   GET POST     /admin/resourceGroups             GET PATCH DELETE /admin/resourceGroups/{id}
///   GET POST     /admin/dockerRegistrySecrets      GET PATCH DELETE /admin/dockerRegistrySecrets/{name}
///   GET POST     /admin/objectStoreSecrets         GET PATCH DELETE /admin/objectStoreSecrets/{name}
///
/// Everything below /lm and /admin/objectStoreSecrets is scoped by the
/// "AI-Resource-Group" header (default: the configured default group).
/// Lists answer {count, resources}, paged by $top / $skip. Errors answer
/// {"error": {code, message, requestId, target}} with 400/401/403/404/409/412/500.
module uim.platform.ai_core.presentation.http.controllers.ai_api;

import std.uni : icmp;
import std.uuid : randomUUID;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// The state of one AI API call.
struct ApiCall {
  RequestContext ctx;
  TenantId t;
  UserId actor;
  ResourceGroupId rg;
  HTTPServerRequest req;
  Json body;

  string query(string name) @trusted {
    return req.query.get(name, "");
  }

  string param(string name) @trusted {
    return req.params.get(name, "");
  }

  string[] queryList(string name) {
    return query(name).split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
  }
}

class AiApiController {
  protected AiCorePorts ports;
  protected SecuritySetup security;
  protected string root;
  protected string defaultGroup;
  protected string serviceVersion;

  this(AiCorePorts ports, SecuritySetup security, string root = "/api/v2", string defaultGroup = "default", string serviceVersion = "2.0.0") {
    this.ports = ports;
    this.security = security;
    this.root = "/" ~ root.strip("/");
    this.defaultGroup = defaultGroup;
    this.serviceVersion = serviceVersion;
  }

  void registerRoutes(URLRouter router) {
    auto lm = root ~ "/lm", admin = root ~ "/admin";

    get(router, lm ~ "/meta", false, (ref ApiCall c) => aiApiMeta(serviceVersion));

    // ── scenarios & executables ───────────────────────────────────────────
    get(router, lm ~ "/scenarios", true, (ref ApiCall c) => listOf(c, ports.scenarios.listScenarios(c.t, c.rg).map!(s => apiScenario(s)).array));
    post(router, lm ~ "/scenarios", 201, (ref ApiCall c) {
      CreateScenarioRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.id = str(c.body, "id");
      r.name = str(c.body, "name");
      r.description = str(c.body, "description");
      r.labels = parseApiLabels(c.body, "labels");
      return apiScenario(ports.scenarios.createScenario(r));
    });
    get(router, lm ~ "/scenarios/:scenarioId", true, (ref ApiCall c) => apiScenario(
        ports.scenarios.getScenario(c.t, c.rg, ScenarioId(c.param("scenarioId")))));
    patch(router, lm ~ "/scenarios/:scenarioId", 200, (ref ApiCall c) {
      UpdateScenarioRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.id = c.param("scenarioId");
      if ("name" in c.body)
        r.name = str(c.body, "name");
      if ("description" in c.body)
        r.description = str(c.body, "description");
      if ("labels" in c.body)
        r.labels = parseApiLabels(c.body, "labels");
      return apiScenario(ports.scenarios.updateScenario(r));
    });
    del(router, lm ~ "/scenarios/:scenarioId", (ref ApiCall c) {
      ports.scenarios.deleteScenario(c.t, c.rg, ScenarioId(c.param("scenarioId")));
      return deleted(c.param("scenarioId"));
    });
    get(router, lm ~ "/scenarios/:scenarioId/versions", true, (ref ApiCall c) {
      auto scenario = ports.scenarios.getScenario(c.t, c.rg, ScenarioId(c.param("scenarioId")));
      string[] versions;
      Json[] rows;
      foreach (e; ports.executables.listExecutables(c.t, c.rg, scenario.id))
        if (!versions.canFind(e.versionId)) {
          versions ~= e.versionId;
          rows ~= Json(["id": Json(e.versionId), "scenarioId": Json(scenario.id.value), "createdAt": Json(isoTimeText(e.createdAt))]);
        }
      return listOf(c, rows);
    });
    get(router, lm ~ "/scenarios/:scenarioId/executables", true, (ref ApiCall c) {
      auto scenario = ports.scenarios.getScenario(c.t, c.rg, ScenarioId(c.param("scenarioId")));
      auto versionFilter = c.query("versionId");
      return listOf(c, ports.executables.listExecutables(c.t, c.rg, scenario.id)
        .filter!(e => versionFilter.length == 0 || e.versionId == versionFilter).map!(e => apiExecutable(e)).array);
    });
    post(router, lm ~ "/scenarios/:scenarioId/executables", 201, (ref ApiCall c) {
      CreateExecutableRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.scenarioId = c.param("scenarioId");
      r.id = str(c.body, "id");
      r.name = str(c.body, "name");
      r.description = str(c.body, "description");
      if ("type" in c.body)
        r.type = str(c.body, "type");
      else if ("deployable" in c.body && c.body["deployable"].type == Json.Type.bool_)
        r.type = c.body["deployable"].get!bool ? "serving" : "workflow";
      if (str(c.body, "versionId").length)
        r.versionId = str(c.body, "versionId");
      r.parameters = parseApiParameters(c.body);
      r.inputArtifacts = parseApiSlots(c.body, "inputArtifacts");
      r.outputArtifacts = parseApiSlots(c.body, "outputArtifacts");
      r.labels = parseApiLabels(c.body, "labels");
      return apiExecutable(ports.executables.createExecutable(r));
    });
    get(router, lm ~ "/scenarios/:scenarioId/executables/:executableId", true, (ref ApiCall c) => apiExecutable(
        executableIn(c, c.param("scenarioId"), c.param("executableId"))));
    patch(router, lm ~ "/scenarios/:scenarioId/executables/:executableId", 200, (ref ApiCall c) {
      executableIn(c, c.param("scenarioId"), c.param("executableId"));
      UpdateExecutableRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.id = c.param("executableId");
      if ("name" in c.body)
        r.name = str(c.body, "name");
      if ("description" in c.body)
        r.description = str(c.body, "description");
      if ("versionId" in c.body)
        r.versionId = str(c.body, "versionId");
      if ("parameters" in c.body)
        r.parameters = parseApiParameters(c.body);
      if ("inputArtifacts" in c.body)
        r.inputArtifacts = parseApiSlots(c.body, "inputArtifacts");
      if ("outputArtifacts" in c.body)
        r.outputArtifacts = parseApiSlots(c.body, "outputArtifacts");
      if ("labels" in c.body)
        r.labels = parseApiLabels(c.body, "labels");
      return apiExecutable(ports.executables.updateExecutable(r));
    });
    del(router, lm ~ "/scenarios/:scenarioId/executables/:executableId", (ref ApiCall c) {
      auto e = executableIn(c, c.param("scenarioId"), c.param("executableId"));
      ports.executables.deleteExecutable(c.t, c.rg, e.id);
      return deleted(e.id.value);
    });
    get(router, lm ~ "/executables", true, (ref ApiCall c) => listOf(c, ports.executables.listExecutables(c.t, c.rg,
        ScenarioId(c.query("scenarioId"))).map!(e => apiExecutable(e)).array));

    // ── configurations ────────────────────────────────────────────────────
    get(router, lm ~ "/configurations/$count", true, (ref ApiCall c) => Json(configurations(c).length));
    get(router, lm ~ "/configurations", true, (ref ApiCall c) => listOf(c, configurations(c).map!(x => apiConfiguration(x)).array));
    post(router, lm ~ "/configurations", 201, (ref ApiCall c) {
      CreateConfigurationRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.name = str(c.body, "name");
      r.scenarioId = str(c.body, "scenarioId");
      r.executableId = str(c.body, "executableId");
      r.parameterBindings = parseApiLabels(c.body, "parameterBindings");
      r.inputArtifactBindings = parseApiRefs(c.body, "inputArtifactBindings");
      auto created = ports.configurations.createConfiguration(r);
      return Json(["id": Json(created.id.value), "message": Json("Configuration created")]);
    });
    get(router, lm ~ "/configurations/:id", true, (ref ApiCall c) => apiConfiguration(
        ports.configurations.getConfiguration(c.t, c.rg, ConfigurationId(c.param("id")))));
    del(router, lm ~ "/configurations/:id", (ref ApiCall c) {
      ports.configurations.deleteConfiguration(c.t, c.rg, ConfigurationId(c.param("id")));
      return deleted(c.param("id"));
    });

    // ── executions ────────────────────────────────────────────────────────
    get(router, lm ~ "/executions/$count", true, (ref ApiCall c) => Json(executions(c).length));
    get(router, lm ~ "/executions", true, (ref ApiCall c) {
      auto names = configurationNames(c);
      return listOf(c, executions(c).map!(e => executionJson(c, e, names)).array);
    });
    post(router, lm ~ "/executions", 202, (ref ApiCall c) {
      CreateExecutionRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.configurationId = str(c.body, "configurationId");
      r.tags = parseApiLabels(c.body, "tags");
      auto e = ports.executions.createExecution(r);
      return Json(["id": Json(e.id.value), "message": Json("Execution scheduled"), "status": Json(cast(string) e.status)]);
    });
    patch(router, lm ~ "/executions", 202, (ref ApiCall c) => bulkJson("executions", c, (string[] ids, string target) =>
        ports.executions.patchExecutions(c.t, c.rg, c.actor, ids, target)));
    get(router, lm ~ "/executions/:id", true, (ref ApiCall c) => executionJson(c,
        ports.executions.getExecution(c.t, c.rg, ExecutionId(c.param("id"))), configurationNames(c)));
    patch(router, lm ~ "/executions/:id", 202, (ref ApiCall c) {
      PatchExecutionRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.id = c.param("id");
      r.targetStatus = str(c.body, "targetStatus");
      auto e = ports.executions.patchExecution(r);
      return Json(["id": Json(e.id.value), "message": Json("Execution modification scheduled"),
          "status": Json(cast(string) e.status), "targetStatus": Json(cast(string) e.targetStatus)]);
    });
    del(router, lm ~ "/executions/:id", (ref ApiCall c) {
      ports.executions.deleteExecution(c.t, c.rg, ExecutionId(c.param("id")));
      return deleted(c.param("id"));
    });

    // ── deployments ───────────────────────────────────────────────────────
    get(router, lm ~ "/deployments/$count", true, (ref ApiCall c) => Json(deployments(c).length));
    get(router, lm ~ "/deployments", true, (ref ApiCall c) {
      auto names = configurationNames(c);
      return listOf(c, deployments(c).map!(d => apiDeployment(d, names.get(d.configurationId.value, ""))).array);
    });
    post(router, lm ~ "/deployments", 202, (ref ApiCall c) {
      CreateDeploymentRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.configurationId = str(c.body, "configurationId");
      r.ttlSeconds = parseTtl(c.body);
      auto d = ports.deployments.createDeployment(r);
      return Json(["id": Json(d.id.value), "deploymentUrl": Json(d.deploymentUrl), "message": Json("Deployment scheduled."),
          "status": Json(cast(string) d.status)]);
    });
    patch(router, lm ~ "/deployments", 202, (ref ApiCall c) => bulkJson("deployments", c, (string[] ids, string target) =>
        ports.deployments.patchDeployments(c.t, c.rg, c.actor, ids, target)));
    get(router, lm ~ "/deployments/:id", true, (ref ApiCall c) {
      auto d = ports.deployments.getDeployment(c.t, c.rg, DeploymentId(c.param("id")));
      return apiDeployment(d, configurationNames(c).get(d.configurationId.value, ""));
    });
    patch(router, lm ~ "/deployments/:id", 202, (ref ApiCall c) {
      PatchDeploymentRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.id = c.param("id");
      r.targetStatus = str(c.body, "targetStatus");
      r.configurationId = str(c.body, "configurationId");
      auto d = ports.deployments.patchDeployment(r);
      return Json(["id": Json(d.id.value), "message": Json("Deployment modification scheduled"),
          "status": Json(cast(string) d.status), "targetStatus": Json(cast(string) d.targetStatus)]);
    });
    del(router, lm ~ "/deployments/:id", (ref ApiCall c) {
      ports.deployments.deleteDeployment(c.t, c.rg, DeploymentId(c.param("id")));
      return deleted(c.param("id"));
    });

    // ── artifacts ─────────────────────────────────────────────────────────
    get(router, lm ~ "/artifacts/$count", true, (ref ApiCall c) => Json(artifacts(c).length));
    get(router, lm ~ "/artifacts", true, (ref ApiCall c) => listOf(c, artifacts(c).map!(a => apiArtifact(a)).array));
    post(router, lm ~ "/artifacts", 201, (ref ApiCall c) {
      CreateArtifactRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.name = str(c.body, "name");
      if (str(c.body, "kind").length)
        r.kind = str(c.body, "kind");
      r.url = str(c.body, "url");
      r.description = str(c.body, "description");
      r.scenarioId = str(c.body, "scenarioId");
      r.executionId = str(c.body, "executionId");
      r.labels = parseApiLabels(c.body, "labels");
      auto a = ports.artifacts.createArtifact(r);
      return Json(["id": Json(a.id.value), "message": Json("Artifact acknowledged"), "url": Json(a.url)]);
    });
    get(router, lm ~ "/artifacts/:id", true, (ref ApiCall c) => apiArtifact(ports.artifacts.getArtifact(c.t, c.rg,
        ArtifactId(c.param("id")))));
    del(router, lm ~ "/artifacts/:id", (ref ApiCall c) {
      ports.artifacts.deleteArtifact(c.t, c.rg, ArtifactId(c.param("id")));
      return deleted(c.param("id"));
    });

    // ── execution schedules ───────────────────────────────────────────────
    get(router, lm ~ "/executionSchedules/$count", true, (ref ApiCall c) => Json(schedules(c).length));
    get(router, lm ~ "/executionSchedules", true, (ref ApiCall c) => listOf(c, schedules(c).map!(s => apiSchedule(s)).array));
    post(router, lm ~ "/executionSchedules", 202, (ref ApiCall c) {
      CreateScheduleRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.name = str(c.body, "name");
      r.configurationId = str(c.body, "configurationId");
      r.cron = str(c.body, "cron");
      if (str(c.body, "status").length)
        r.status = str(c.body, "status");
      r.startTime = timeIn(c.body, "start");
      r.endTime = timeIn(c.body, "end");
      auto s = ports.schedules.createSchedule(r);
      return Json(["id": Json(s.id.value), "message": Json("Execution Schedule created"), "status": Json(cast(string) s.status)]);
    });
    get(router, lm ~ "/executionSchedules/:id", true, (ref ApiCall c) => apiSchedule(ports.schedules.getSchedule(c.t,
        c.rg, ScheduleId(c.param("id")))));
    patch(router, lm ~ "/executionSchedules/:id", 202, (ref ApiCall c) {
      UpdateScheduleRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.id = c.param("id");
      if ("name" in c.body)
        r.name = str(c.body, "name");
      if ("cron" in c.body)
        r.cron = str(c.body, "cron");
      if ("status" in c.body)
        r.status = str(c.body, "status");
      if ("start" in c.body)
        r.startTime = timeIn(c.body, "start");
      if ("end" in c.body)
        r.endTime = timeIn(c.body, "end");
      auto s = ports.schedules.updateSchedule(r);
      return Json(["id": Json(s.id.value), "message": Json("Execution Schedule modified")]);
    });
    del(router, lm ~ "/executionSchedules/:id", (ref ApiCall c) {
      ports.schedules.deleteSchedule(c.t, c.rg, ScheduleId(c.param("id")));
      return deleted(c.param("id"));
    });

    // ── metrics ───────────────────────────────────────────────────────────
    get(router, lm ~ "/metrics", true, (ref ApiCall c) {
      auto ids = c.queryList("executionIds");
      if (ids.length == 0 && c.query("executionId").length)
        ids = [c.query("executionId")];
      if (ids.length == 0)
        ids = ports.executions.listExecutions(c.t, c.rg).map!(e => e.id.value).array;
      Json[] rows;
      foreach (id; ids) {
        auto e = ports.executions.getExecution(c.t, c.rg, ExecutionId(id));
        rows ~= apiMetricResource(id, ports.metrics.listMetrics(c.t, c.rg, e.id), e.tags);
      }
      return listOf(c, rows);
    });
    patch(router, lm ~ "/metrics", 204, (ref ApiCall c) {
      LogMetricsRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.executionId = str(c.body, "executionId");
      r.metrics = parseApiMetrics(c.body);
      r.tags = parseApiLabels(c.body, "tags");
      ports.metrics.logMetrics(r);
      return Json(null);
    });
    del(router, lm ~ "/metrics", (ref ApiCall c) {
      auto id = c.query("executionId");
      if (id.length == 0)
        throw AiCoreException.invalid("Query parameter executionId is required");
      auto removed = ports.metrics.clearMetrics(c.t, c.rg, ExecutionId(id));
      return Json(["id": Json(id), "message": Json("Metrics deleted"), "count": Json(removed)]);
    });

    // ── admin: resource groups ────────────────────────────────────────────
    get(router, admin ~ "/resourceGroups", false, (ref ApiCall c) => listOf(c,
        ports.resourceGroups.listResourceGroups(c.t).map!(g => apiResourceGroup(g)).array));
    route(router, "POST", admin ~ "/resourceGroups", manageScope, 202, false, (ref ApiCall c) {
      CreateResourceGroupRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.id = str(c.body, "resourceGroupId");
      r.labels = parseApiLabels(c.body, "labels");
      auto g = ports.resourceGroups.createResourceGroup(r);
      return Json(["resourceGroupId": Json(g.id.value), "tenantId": Json(g.tenantId.value), "zoneId": Json(g.tenantId.value),
          "message": Json("Resource group created")]);
    });
    get(router, admin ~ "/resourceGroups/:id", false, (ref ApiCall c) => apiResourceGroup(
        ports.resourceGroups.getResourceGroup(c.t, ResourceGroupId(c.param("id")))));
    route(router, "PATCH", admin ~ "/resourceGroups/:id", manageScope, 202, false, (ref ApiCall c) {
      UpdateResourceGroupRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.id = c.param("id");
      if ("labels" in c.body)
        r.labels = parseApiLabels(c.body, "labels");
      ports.resourceGroups.updateResourceGroup(r);
      return Json(["id": Json(r.id), "message": Json("Resource group modified")]);
    });
    route(router, "DELETE", admin ~ "/resourceGroups/:id", manageScope, 202, false, (ref ApiCall c) {
      auto removed = ports.resourceGroups.deleteResourceGroup(c.t, ResourceGroupId(c.param("id")));
      auto j = deleted(c.param("id"));
      j["removedResources"] = removed;
      return j;
    });

    // ── admin: docker registry secrets (tenant wide) ──────────────────────
    get(router, admin ~ "/dockerRegistrySecrets", false, (ref ApiCall c) => listOf(c,
        ports.secrets.listDockerRegistrySecrets(c.t).map!(s => apiDockerSecret(s)).array));
    route(router, "POST", admin ~ "/dockerRegistrySecrets", manageScope, 201, false, (ref ApiCall c) {
      CreateDockerRegistrySecretRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.id = str(c.body, "name");
      dockerCredentials(c.body, r.server, r.username, r.password);
      ports.secrets.createDockerRegistrySecret(r);
      return Json(["id": Json(r.id), "message": Json("Secret has been created")]);
    });
    get(router, admin ~ "/dockerRegistrySecrets/:name", false, (ref ApiCall c) => apiDockerSecret(
        ports.secrets.getDockerRegistrySecret(c.t, DockerRegistrySecretId(c.param("name")))));
    route(router, "PATCH", admin ~ "/dockerRegistrySecrets/:name", manageScope, 202, false, (ref ApiCall c) {
      UpdateDockerRegistrySecretRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.id = c.param("name");
      string server, user, password;
      dockerCredentials(c.body, server, user, password);
      if (server.length)
        r.server = server;
      if (user.length)
        r.username = user;
      if (password.length)
        r.password = password;
      ports.secrets.updateDockerRegistrySecret(r);
      return Json(["id": Json(r.id), "message": Json("Secret has been modified")]);
    });
    route(router, "DELETE", admin ~ "/dockerRegistrySecrets/:name", manageScope, 202, false, (ref ApiCall c) {
      ports.secrets.deleteDockerRegistrySecret(c.t, DockerRegistrySecretId(c.param("name")));
      return deleted(c.param("name"));
    });

    // ── admin: object store secrets (per resource group) ──────────────────
    get(router, admin ~ "/objectStoreSecrets", true, (ref ApiCall c) => listOf(c,
        ports.secrets.listObjectStoreSecrets(c.t, c.rg).map!(s => apiObjectStoreSecret(s)).array));
    post(router, admin ~ "/objectStoreSecrets", 201, (ref ApiCall c) {
      CreateObjectStoreSecretRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.id = str(c.body, "name");
      if (str(c.body, "type").length)
        r.type = str(c.body, "type");
      r.bucket = str(c.body, "bucket");
      r.endpoint = str(c.body, "endpoint");
      r.region = str(c.body, "region");
      r.pathPrefix = str(c.body, "pathPrefix");
      storeCredentials(c.body, r.accessKeyId, r.secretAccessKey);
      ports.secrets.createObjectStoreSecret(r);
      return Json(["id": Json(r.id), "message": Json("Secret has been created")]);
    });
    get(router, admin ~ "/objectStoreSecrets/:name", true, (ref ApiCall c) => apiObjectStoreSecret(
        ports.secrets.getObjectStoreSecret(c.t, c.rg, ObjectStoreSecretId(c.param("name")))));
    patch(router, admin ~ "/objectStoreSecrets/:name", 202, (ref ApiCall c) {
      UpdateObjectStoreSecretRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.resourceGroupId = c.rg;
      r.id = c.param("name");
      if ("bucket" in c.body)
        r.bucket = str(c.body, "bucket");
      if ("endpoint" in c.body)
        r.endpoint = str(c.body, "endpoint");
      if ("region" in c.body)
        r.region = str(c.body, "region");
      if ("pathPrefix" in c.body)
        r.pathPrefix = str(c.body, "pathPrefix");
      string key, secret;
      storeCredentials(c.body, key, secret);
      if (secret.length) {
        r.accessKeyId = key;
        r.secretAccessKey = secret;
      }
      ports.secrets.updateObjectStoreSecret(r);
      return Json(["id": Json(r.id), "message": Json("Secret has been modified")]);
    });
    del(router, admin ~ "/objectStoreSecrets/:name", (ref ApiCall c) {
      ports.secrets.deleteObjectStoreSecret(c.t, c.rg, ObjectStoreSecretId(c.param("name")));
      return deleted(c.param("name"));
    });
  }

  // ── queries ───────────────────────────────────────────────────────────────
  protected Configuration[] configurations(ref ApiCall c) {
    ConfigurationFilter f;
    f.scenarioId = ScenarioId(c.query("scenarioId"));
    auto executables = c.queryList("executableIds");
    return ports.configurations.listConfigurations(c.t, c.rg, f)
      .filter!(x => executables.length == 0 || executables.canFind(x.executableId.value)).array;
  }

  protected RunFilter runFilter(ref ApiCall c) {
    RunFilter f;
    f.scenarioId = ScenarioId(c.query("scenarioId"));
    f.configurationId = ConfigurationId(c.query("configurationId"));
    f.status = c.query("status");
    return f;
  }

  protected Execution[] executions(ref ApiCall c) {
    auto executables = c.queryList("executableIds");
    auto schedule = c.query("executionScheduleId");
    return ports.executions.listExecutions(c.t, c.rg, runFilter(c))
      .filter!(e => (executables.length == 0 || executables.canFind(e.executableId.value))
          && (schedule.length == 0 || e.scheduleId.value == schedule)).array;
  }

  protected Deployment[] deployments(ref ApiCall c) {
    auto executables = c.queryList("executableIds");
    return ports.deployments.listDeployments(c.t, c.rg, runFilter(c))
      .filter!(d => executables.length == 0 || executables.canFind(d.executableId.value)).array;
  }

  protected Artifact[] artifacts(ref ApiCall c) {
    ArtifactFilter f;
    f.scenarioId = ScenarioId(c.query("scenarioId"));
    f.executionId = ExecutionId(c.query("executionId"));
    f.kind = c.query("kind");
    f.name = c.query("name");
    return ports.artifacts.listArtifacts(c.t, c.rg, f);
  }

  protected ExecutionSchedule[] schedules(ref ApiCall c) {
    auto status = c.query("status");
    return ports.schedules.listSchedules(c.t, c.rg, ConfigurationId(c.query("configurationId")))
      .filter!(s => status.length == 0 || icmp(status, cast(string) s.status) == 0).array;
  }

  protected string[string] configurationNames(ref ApiCall c) {
    string[string] names;
    foreach (x; ports.configurations.listConfigurations(c.t, c.rg))
      names[x.id.value] = x.name;
    return names;
  }

  protected Json executionJson(ref ApiCall c, const Execution e, string[string] names) {
    auto t = c.t, rg = c.rg;
    return apiExecution(e, names.get(e.configurationId.value, ""), (ArtifactId id) {
      try
        return ports.artifacts.getArtifact(t, rg, id);
      catch (AiCoreException)
        return Artifact.init;
    });
  }

  protected Executable executableIn(ref ApiCall c, string scenarioId, string executableId) {
    auto e = ports.executables.getExecutable(c.t, c.rg, ExecutableId(executableId));
    if (e.scenarioId.value != scenarioId)
      throw AiCoreException.notFound("Executable '" ~ executableId ~ "' of scenario '" ~ scenarioId ~ "'");
    return e;
  }

  /// {count, resources} with $top / $skip.
  protected static Json listOf(ref ApiCall c, Json[] rows) {
    auto skip = number(c.query("$skip"), 0);
    auto top = number(c.query("$top"), rows.length);
    auto from = min(skip, rows.length);
    auto to = min(from + top, rows.length);
    auto j = Json.emptyObject;
    j["count"] = rows.length;
    j["resources"] = Json(rows[from .. to]);
    return j;
  }

  protected static size_t number(string text, size_t fallback) {
    if (text.length == 0)
      return fallback;
    try
      return text.to!size_t;
    catch (Exception)
      throw AiCoreException.invalid("Invalid paging value '" ~ text ~ "'");
  }

  protected static Json deleted(string id) {
    return Json(["id": Json(id), "message": Json("Deletion scheduled"), "targetStatus": Json("DELETED")]);
  }

  protected static long timeIn(Json body, string field) {
    try
      return parseIsoTime(str(body, field));
    catch (Exception)
      throw AiCoreException.invalid("'" ~ field ~ "' must be an ISO 8601 timestamp");
  }

  /// Body: {name, server, username, password} or {name, data: {".dockerconfigjson": "..."}}.
  protected static void dockerCredentials(Json body, out string server, out string username, out string password) {
    if ("data" in body && body["data"].type == Json.Type.object && str(body["data"], ".dockerconfigjson").length) {
      parseDockerConfig(str(body["data"], ".dockerconfigjson"), server, username, password);
      return;
    }
    server = str(body, "server");
    username = str(body, "username");
    password = str(body, "password");
  }

  /// Body: {data: {AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY}} (or accessKeyId / secretAccessKey).
  protected static void storeCredentials(Json body, out string key, out string secret) {
    auto data = "data" in body && body["data"].type == Json.Type.object ? body["data"] : body;
    key = str(data, "AWS_ACCESS_KEY_ID").length ? str(data, "AWS_ACCESS_KEY_ID") : str(data, "accessKeyId");
    secret = str(data, "AWS_SECRET_ACCESS_KEY").length ? str(data, "AWS_SECRET_ACCESS_KEY") : str(data, "secretAccessKey");
  }

  /// Bulk PATCH body: {"<field>": [{"id": "...", "targetStatus": "STOPPED"}, ...]}.
  protected static Json bulkJson(string field, ref ApiCall c, scope BulkResult[] delegate(string[], string) @safe op) @trusted {
    if (field !in c.body || c.body[field].type != Json.Type.array || c.body[field].length == 0)
      throw AiCoreException.invalid("Body must contain a non-empty '" ~ field ~ "' array");
    Json[] items;
    foreach (item; c.body[field].get!(Json[])) {
      auto results = op([str(item, "id")], str(item, "targetStatus"));
      auto b = results[0];
      auto j = Json(["id": Json(b.id)]);
      if (b.ok)
        j["message"] = (field == "executions" ? "Execution" : "Deployment") ~ " modification scheduled";
      else
        j["error"] = Json(["code": Json(b.status.to!string), "message": Json(b.message)]);
      items ~= j;
    }
    return Json([field: Json(items)]);
  }

  // ── routing ───────────────────────────────────────────────────────────────
  protected void get(URLRouter router, string path, bool scoped, Json delegate(ref ApiCall) @safe action) {
    route(router, "GET", path, readScope, 200, scoped, action);
  }

  protected void post(URLRouter router, string path, int status, Json delegate(ref ApiCall) @safe action) {
    route(router, "POST", path, manageScope, status, true, action);
  }

  protected void patch(URLRouter router, string path, int status, Json delegate(ref ApiCall) @safe action) {
    route(router, "PATCH", path, manageScope, status, true, action);
  }

  protected void del(URLRouter router, string path, Json delegate(ref ApiCall) @safe action) {
    route(router, "DELETE", path, manageScope, 202, true, action);
  }

  protected void route(URLRouter router, string method, string path, string scope_, int okStatus, bool scoped,
    Json delegate(ref ApiCall) @safe action) {
    auto handler = (HTTPServerRequest req, HTTPServerResponse res) @safe {
      serve(req, res, method, scope_, okStatus, scoped, action);
    };
    switch (method) {
    case "GET":
      router.get(path, handler);
      break;
    case "POST":
      router.post(path, handler);
      break;
    case "PATCH":
      router.patch(path, handler);
      break;
    default:
      router.delete_(path, handler);
    }
  }

  protected void serve(HTTPServerRequest req, HTTPServerResponse res, string method, string scope_, int okStatus,
    bool scoped, scope Json delegate(ref ApiCall) @safe action) @trusted {
    int status = okStatus;
    Json body;
    auto requestId = randomUUID.toString;
    try {
      ApiCall c;
      c.req = req;
      c.ctx = security.resolve(req, "aiapi");
      if (security.requireAuthentication && !c.ctx.authenticated) {
        status = 401;
        body = errorBody("401", "A valid bearer token is required", requestId, req.requestPath.toString);
      } else if (!security.permits(c.ctx, scope_)) {
        status = 403;
        body = errorBody("403", "Missing scope '" ~ scope_ ~ "'", requestId, req.requestPath.toString);
      } else {
        c.t = TenantId(c.ctx.tenantId);
        c.actor = UserId(c.ctx.actor);
        if (scoped) {
          auto group = req.headers.get("AI-Resource-Group", defaultGroup).strip;
          if (group.length == 0)
            throw AiCoreException.invalid("Header AI-Resource-Group is required");
          c.rg = ResourceGroupId(group);
        }
        c.body = method == "POST" || method == "PATCH" ? bodyOf(req) : Json.emptyObject;
        body = action(c);
      }
    } catch (AiCoreException e) {
      final switch (e.kind) {
      case AiCoreErrorKind.invalid:
        status = 400;
        break;
      case AiCoreErrorKind.notFound:
        status = 404;
        break;
      case AiCoreErrorKind.conflict:
        status = 409;
        break;
      case AiCoreErrorKind.ruleViolation:
        status = 412;
        break;
      }
      body = errorBody(status.to!string, e.msg, requestId, req.requestPath.toString);
    } catch (Exception e) {
      status = 500;
      body = errorBody("500", "Internal error", requestId, req.requestPath.toString);
      logServiceEvent("error", "unhandled AI API error", Json([
          "path": Json(req.requestPath.toString), "error": Json(e.msg), "requestId": Json(requestId)
        ]));
    }
    res.headers["Cache-Control"] = "no-store";
    if (status == 204) {
      res.statusCode = 204;
      res.writeVoidBody();
    } else
      res.writeJsonBody(body, status);
  }

  static Json bodyOf(HTTPServerRequest req) @trusted {
    auto text = req.bodyReader.readAllUTF8(false, 4 * 1024 * 1024);
    if (text.strip.length == 0)
      return Json.emptyObject;
    Json j;
    try
      j = parseJsonString(text);
    catch (Exception e)
      throw AiCoreException.invalid("Request body is not valid JSON: " ~ e.msg);
    if (!j.isObject)
      throw AiCoreException.invalid("Request body must be a JSON object");
    return j;
  }

  static Json errorBody(string code, string message, string requestId, string target) {
    auto e = Json.emptyObject;
    e["code"] = code;
    e["message"] = message;
    e["requestId"] = requestId;
    e["target"] = target;
    e["details"] = Json.emptyArray;
    return Json(["error": e]);
  }
}
