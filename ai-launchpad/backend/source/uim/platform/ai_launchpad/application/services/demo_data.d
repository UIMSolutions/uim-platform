/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo content for an empty tenant: two workspaces, a validated and a
/// broken connection, resource groups, two scenarios with datasets,
/// configurations, running executions and a deployment, a model and the
/// prompts of a customer support collection. Everything goes through the
/// driving ports, so every business rule applies. No user accounts are
/// created (passwords are never seeded).
module uim.platform.ai_launchpad.application.services.demo_data;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

SeedResult seedDemoData(AilpPorts ports, TenantId t, UserId actor) {
  if (ports.workspaces.list(t).length > 0)
    throw AilpException.ruleViolation("Demo content can only be created in a tenant without workspaces");
  SeedResult r;

  void workspace(string id, string name, string description) {
    ports.workspaces.create(createCommand(t, actor, id, WorkspaceInput(name, description, "active")));
    r.workspaces++;
  }

  void connection(string id, string workspace, string name, string url, string description) {
    ConnectionInput i;
    i.workspaceId = workspace;
    i.name = name;
    i.description = description;
    i.url = url;
    i.authUrl = url.replace("api.ai.", "auth.").replace("/v2", "") ~ "/oauth/token";
    i.clientId = "sb-" ~ id ~ "!b1234";
    i.clientSecret = "demo-secret-" ~ id;
    ports.connections.create(createCommand(t, actor, id, i));
    ports.connections.validateConnection(t, ConnectionId(id), actor);
    r.connections++;
  }

  void group(string id, string connection, string description, string[] labels) {
    ports.resourceGroups.create(createCommand(t, actor, id, ResourceGroupInput(connection, description, labels, "ready")));
    r.resourceGroups++;
  }

  void scenario(string id, string connection, string name, string description, string[] executables) {
    ports.scenarios.create(createCommand(t, actor, id, ScenarioInput(connection, name, description, executables,
        ["ext.ai.sap.com/domain=" ~ id])));
    r.scenarios++;
  }

  void dataset(string id, string scenario, string name, string url, double mib) {
    DatasetInput i;
    i.scenarioId = scenario;
    i.name = name;
    i.description = "Demo data";
    i.url = url;
    i.sizeMiB = mib;
    ports.datasets.create(createCommand(t, actor, id, i));
    r.datasets++;
  }

  void configuration(string id, string scenario, string name, string executable, string[] parameters, string[] inputs) {
    ports.configurations.create(createCommand(t, actor, id, ConfigurationInput(scenario, name, executable, parameters, inputs)));
    r.configurations++;
  }

  void prompt(string id, string collection, string name, string system, string user, string status, double temperature) {
    PromptInput i;
    i.collectionId = collection;
    i.name = name;
    i.systemMessage = system;
    i.userMessage = user;
    i.status = status;
    i.temperature = temperature;
    ports.prompts.create(createCommand(t, actor, id, i));
    r.prompts++;
  }

  // runtimes
  workspace("ml-team", "ML Team", "Classic machine learning: fraud detection and forecasting");
  workspace("genai-lab", "GenAI Lab", "Generative AI use cases of the service desk");
  connection("aicore-eu", "ml-team", "SAP AI Core (EU)", "https://api.ai.prod.eu-central-1.example.com/v2",
    "Productive AI Core tenant");
  connection("aicore-legacy", "ml-team", "AI Core (legacy, unreachable)", "https://api.ai.unreachable.example.com/v2",
    "Decommissioned tenant — validation fails");
  group("default", "aicore-eu", "Default resource group", []);
  group("fraud-team", "aicore-eu", "Capacity of the fraud team", ["ext.ai.sap.com/team=fraud"]);

  // life cycle
  scenario("fraud-detection", "aicore-eu", "Fraud Detection", "Detect fraudulent card transactions",
    ["training", "serving"]);
  scenario("demand-forecast", "aicore-eu", "Demand Forecast", "Forecast the demand per product and store",
    ["training", "batch-scoring"]);
  dataset("transactions-2026", "fraud-detection", "Card transactions 2026", "s3://demo-bucket/fraud/transactions-2026.parquet",
    2048);
  dataset("sales-history", "demand-forecast", "Sales history", "s3://demo-bucket/forecast/sales-history.csv", 512);
  configuration("fraud-train", "fraud-detection", "Fraud training (XGBoost)", "training", [
      "epochs=20", "learningRate=0.001"
    ], ["trainingData=transactions-2026"]);
  configuration("fraud-serve", "fraud-detection", "Fraud serving", "serving", ["modelVersion=1"], []);
  configuration("forecast-train", "demand-forecast", "Forecast training (Prophet)", "training", [
      "horizonDays=30", "simulate.outcome=failed"
    ], ["trainingData=sales-history"]);

  ModelInput m;
  m.scenarioId = "fraud-detection";
  m.name = "fraud-xgb";
  m.version_ = "1";
  m.description = "Imported baseline model";
  m.url = "ai://default/models/fraud-xgb/1";
  m.sizeMiB = 48;
  ports.models.create(createCommand(t, actor, "fraud-xgb-1", m));
  r.models++;

  ports.executions.create(createCommand(t, actor, "", ExecutionInput("fraud-train", "fraud-team")));
  ports.executions.create(createCommand(t, actor, "", ExecutionInput("forecast-train", "default")));
  r.executions = 2;
  DeploymentInput d;
  d.configurationId = "fraud-serve";
  d.resourceGroupId = "default";
  d.minReplicas = 1;
  d.maxReplicas = 3;
  ports.deployments.create(createCommand(t, actor, "fraud-api", d));
  r.deployments++;
  ports.reconciler.reconcile(t, actor);

  // generative AI hub
  ports.promptCollections.create(createCommand(t, actor, "service-desk", PromptCollectionInput("genai-lab", "Service Desk",
      "Prompts of the customer service desk")));
  ports.promptCollections.create(createCommand(t, actor, "engineering", PromptCollectionInput("genai-lab", "Engineering",
      "Prompts for developers")));
  r.promptCollections = 2;
  prompt("summarize-ticket", "service-desk", "Summarize ticket", "You are a support agent. Answer in {{language}}.",
    "Summarize the following ticket in three bullet points:\n\n{{ticket}}", "active", 0.3);
  prompt("classify-ticket", "service-desk", "Classify ticket", "Classify tickets into: billing, technical, account, other.",
    "Ticket: {{ticket}}\nCategory:", "active", 0);
  prompt("release-notes", "engineering", "Release notes", "", "Write release notes for version {{version}} from these commits:\n{{commits}}",
    "draft", 0.7);
  return r;
}
