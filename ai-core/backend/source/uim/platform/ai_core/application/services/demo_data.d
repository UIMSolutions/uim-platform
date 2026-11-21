/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo content for an empty tenant (CLI "seed", OData action SeedDemoData):
/// a text classification scenario (training workflow + serving template,
/// dataset, model, configurations, an execution with metrics, a deployment
/// and a nightly schedule) and a forecasting scenario in a second group.
module uim.platform.ai_core.application.services.demo_data;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct DemoDataResult {
  size_t resourceGroups;
  size_t scenarios;
  size_t executables;
  size_t configurations;
  size_t artifacts;
  size_t executions;
  size_t deployments;
  size_t schedules;
  size_t metrics;
  size_t secrets;
}

DemoDataResult seedDemoData(AiCorePorts ports, TenantId t, UserId actor) {
  if (ports.resourceGroups.listResourceGroups(t).length > 0)
    throw AiCoreException.conflict("Tenant '" ~ t.value ~ "' is not empty");
  DemoDataResult r;

  ResourceGroupId group(string id, Label[] labels) {
    CreateResourceGroupRequest g;
    g.tenantId = t;
    g.actor = actor;
    g.id = id;
    g.labels = labels;
    ports.resourceGroups.createResourceGroup(g);
    r.resourceGroups++;
    return ResourceGroupId(id);
  }

  auto def = group("default", [Label("ext.ai.sap.com/owner", "platform-team")]);
  auto forecast = group("team-forecast", [Label("ext.ai.sap.com/owner", "supply-chain"), Label("cost-center", "4711")]);

  CreateDockerRegistrySecretRequest docker;
  docker.tenantId = t;
  docker.actor = actor;
  docker.id = "acme-registry";
  docker.server = "registry.acme.example";
  docker.username = "ml-bot";
  docker.password = "demo-password";
  ports.secrets.createDockerRegistrySecret(docker);
  r.secrets++;

  CreateObjectStoreSecretRequest store;
  store.tenantId = t;
  store.actor = actor;
  store.resourceGroupId = def;
  store.id = "default";
  store.type = "S3";
  store.bucket = "acme-ai-artifacts";
  store.region = "eu-central-1";
  store.endpoint = "s3.eu-central-1.amazonaws.com";
  store.pathPrefix = "ai-core";
  store.accessKeyId = "AKIADEMO";
  store.secretAccessKey = "demo-secret";
  ports.secrets.createObjectStoreSecret(store);
  r.secrets++;

  // ── text classification ─────────────────────────────────────────────────
  CreateScenarioRequest scn;
  scn.tenantId = t;
  scn.actor = actor;
  scn.resourceGroupId = def;
  scn.id = "text-classification";
  scn.name = "Support Ticket Classification";
  scn.description = "Routes incoming support tickets to the responsible team";
  scn.labels = [Label("ext.ai.sap.com/domain", "customer-service")];
  ports.scenarios.createScenario(scn);
  r.scenarios++;

  CreateExecutableRequest train;
  train.tenantId = t;
  train.actor = actor;
  train.resourceGroupId = def;
  train.id = "text-clf-train";
  train.scenarioId = "text-classification";
  train.name = "Fine-tune text classifier";
  train.description = "Fine-tunes a transformer on labelled tickets";
  train.type = "workflow";
  train.versionId = "1.2.0";
  train.parameters = [ParameterDef("base-model", "string", "distilbert-base-multilingual", "Hugging Face base model"),
    ParameterDef("epochs", "string", "5", "Training epochs"), ParameterDef("learning-rate", "string", "0.00002", "Learning rate")];
  train.inputArtifacts = [ArtifactSlot("training-data", ArtifactKind.dataset, "Labelled tickets (CSV)")];
  train.outputArtifacts = [ArtifactSlot("model", ArtifactKind.model, "Fine-tuned model"),
    ArtifactSlot("evaluation", ArtifactKind.resultset, "Evaluation report")];
  ports.executables.createExecutable(train);

  CreateExecutableRequest serve;
  serve.tenantId = t;
  serve.actor = actor;
  serve.resourceGroupId = def;
  serve.id = "text-clf-serve";
  serve.scenarioId = "text-classification";
  serve.name = "Serve text classifier";
  serve.description = "REST inference server (KServe)";
  serve.type = "serving";
  serve.versionId = "1.2.0";
  serve.parameters = [ParameterDef("replicas", "string", "1", "Minimum replicas"),
    ParameterDef("resource-plan", "string", "starter", "Resource plan")];
  serve.inputArtifacts = [ArtifactSlot("model", ArtifactKind.model, "Model to serve")];
  ports.executables.createExecutable(serve);
  r.executables += 2;

  CreateArtifactRequest data;
  data.tenantId = t;
  data.actor = actor;
  data.resourceGroupId = def;
  data.id = "support-tickets-2026";
  data.name = "support-tickets-2026";
  data.kind = "dataset";
  data.url = "ai://default/datasets/support-tickets-2026.csv";
  data.description = "48 211 labelled support tickets (Jan–Jun 2026)";
  data.scenarioId = "text-classification";
  ports.artifacts.createArtifact(data);

  CreateArtifactRequest model;
  model.tenantId = t;
  model.actor = actor;
  model.resourceGroupId = def;
  model.id = "text-clf-v1";
  model.name = "text-clf-v1";
  model.kind = "model";
  model.url = "ai://default/models/text-clf/v1";
  model.description = "Baseline model, F1 0.87";
  model.scenarioId = "text-classification";
  model.labels = [Label("ext.ai.sap.com/version", "1")];
  ports.artifacts.createArtifact(model);
  r.artifacts += 2;

  CreateConfigurationRequest trainCfg;
  trainCfg.tenantId = t;
  trainCfg.actor = actor;
  trainCfg.resourceGroupId = def;
  trainCfg.id = "train-default";
  trainCfg.name = "Train on 2026 tickets";
  trainCfg.scenarioId = "text-classification";
  trainCfg.executableId = "text-clf-train";
  trainCfg.parameterBindings = [Label("epochs", "8")];
  trainCfg.inputArtifactBindings = [ArtifactRef("training-data", ArtifactId("support-tickets-2026"))];
  ports.configurations.createConfiguration(trainCfg);

  CreateConfigurationRequest serveCfg;
  serveCfg.tenantId = t;
  serveCfg.actor = actor;
  serveCfg.resourceGroupId = def;
  serveCfg.id = "serve-v1";
  serveCfg.name = "Serve model v1";
  serveCfg.scenarioId = "text-classification";
  serveCfg.executableId = "text-clf-serve";
  serveCfg.parameterBindings = [Label("replicas", "2")];
  serveCfg.inputArtifactBindings = [ArtifactRef("model", ArtifactId("text-clf-v1"))];
  ports.configurations.createConfiguration(serveCfg);
  r.configurations += 2;

  CreateScheduleRequest nightly;
  nightly.tenantId = t;
  nightly.actor = actor;
  nightly.resourceGroupId = def;
  nightly.id = "nightly-retraining";
  nightly.name = "Nightly retraining";
  nightly.configurationId = "train-default";
  nightly.cron = "0 2 * * *";
  ports.schedules.createSchedule(nightly);
  r.schedules++;

  // ── demand forecast ─────────────────────────────────────────────────────
  CreateScenarioRequest fc;
  fc.tenantId = t;
  fc.actor = actor;
  fc.resourceGroupId = forecast;
  fc.id = "demand-forecast";
  fc.name = "Demand Forecast";
  fc.description = "Weekly demand forecast per material and plant";
  ports.scenarios.createScenario(fc);
  r.scenarios++;

  CreateExecutableRequest fcTrain;
  fcTrain.tenantId = t;
  fcTrain.actor = actor;
  fcTrain.resourceGroupId = forecast;
  fcTrain.id = "forecast-batch";
  fcTrain.scenarioId = "demand-forecast";
  fcTrain.name = "Batch forecast";
  fcTrain.type = "workflow";
  fcTrain.parameters = [ParameterDef("horizon-days", "string", "28"), ParameterDef("plant")];
  fcTrain.outputArtifacts = [ArtifactSlot("forecast", ArtifactKind.resultset, "Forecast per material")];
  ports.executables.createExecutable(fcTrain);
  r.executables++;

  CreateConfigurationRequest fcCfg;
  fcCfg.tenantId = t;
  fcCfg.actor = actor;
  fcCfg.resourceGroupId = forecast;
  fcCfg.id = "forecast-plant-1000";
  fcCfg.name = "Plant 1000, 4 weeks";
  fcCfg.scenarioId = "demand-forecast";
  fcCfg.executableId = "forecast-batch";
  fcCfg.parameterBindings = [Label("plant", "1000")];
  ports.configurations.createConfiguration(fcCfg);
  r.configurations++;

  // ── runs (need provisioned groups) ──────────────────────────────────────
  if (ports.resourceGroups.getResourceGroup(t, def).isProvisioned) {
    CreateExecutionRequest run;
    run.tenantId = t;
    run.actor = actor;
    run.resourceGroupId = def;
    run.configurationId = "train-default";
    run.tags = [Label("triggered-by", "demo")];
    auto execution = ports.executions.createExecution(run);
    r.executions++;

    LogMetricsRequest m;
    m.tenantId = t;
    m.actor = actor;
    m.resourceGroupId = def;
    m.executionId = execution.id.value;
    foreach (step; 1 .. 6) {
      m.metrics ~= MetricInput("loss", 0.9 / step, step);
      m.metrics ~= MetricInput("accuracy", 0.6 + 0.06 * step, step);
    }
    m.tags = [Label("dataset-version", "2026-06")];
    r.metrics += ports.metrics.logMetrics(m);

    CreateDeploymentRequest dep;
    dep.tenantId = t;
    dep.actor = actor;
    dep.resourceGroupId = def;
    dep.configurationId = "serve-v1";
    ports.deployments.createDeployment(dep);
    r.deployments++;
  }
  if (ports.resourceGroups.getResourceGroup(t, forecast).isProvisioned) {
    CreateExecutionRequest run;
    run.tenantId = t;
    run.actor = actor;
    run.resourceGroupId = forecast;
    run.configurationId = "forecast-plant-1000";
    ports.executions.createExecution(run);
    r.executions++;
  }
  return r;
}
