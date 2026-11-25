/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo content for an empty tenant: a small SAP landscape, destinations,
/// three scenarios (two active) and two workflows — one of them running.
/// Everything goes through the driving ports, so all business rules apply.
module uim.platform.integration_automation.application.services.demo_data;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

SeedResult seedDemoData(IaPorts ports, TenantId t, UserId actor) {
  if (ports.systems.list(t).length || ports.scenarios.list(t).length || ports.destinations.list(t).length)
    throw IaException.conflict("Tenant '" ~ t.value ~ "' is not empty — demo content is only created in an empty tenant");
  SeedResult r;

  void system(string id, string name, string type, string host, string environment, string region, string sid = "") {
    SystemInput i;
    i.name = name;
    i.systemType = type;
    i.host = host;
    i.environment = environment;
    i.region = region;
    i.sid = sid;
    i.description = name ~ " (demo)";
    ports.systems.create(createCommand(t, actor, id, i));
    r.systems++;
  }

  system("s4-cloud-prd", "SAP S/4HANA Cloud — Production", "sapS4HanaCloud", "my400123.s4hana.cloud.sap", "production", "eu10", "S4P");
  system("sf-prd", "SAP SuccessFactors — Production", "sapSuccessFactors", "api55.sapsf.eu", "production", "eu10");
  system("btp-eu10", "SAP BTP Subaccount (eu10)", "sapBtp", "uim-prod.authentication.eu10.hana.ondemand.com", "production", "eu10");
  system("ariba-test", "SAP Ariba Test Realm", "sapAriba", "openapi.eu.cloud.ariba.com", "test", "eu");

  void destination(string id, string name, string type, string url, string system, string auth, string user = "",
    string tokenUrl = "") {
    DestinationInput i;
    i.name = name;
    i.destinationType = type;
    i.url = url;
    i.systemId = system;
    i.authentication = auth;
    i.user = user;
    i.tokenServiceUrl = tokenUrl;
    i.description = "Demo destination " ~ name;
    ports.destinations.create(createCommand(t, actor, id, i));
    r.destinations++;
  }

  destination("s4-bp", "S4_BUSINESS_PARTNER", "odata", "https://my400123-api.s4hana.cloud.sap/sap/opu/odata/sap/API_BUSINESS_PARTNER",
    "s4-cloud-prd", "oauth2ClientCredentials", "", "https://my400123-api.s4hana.cloud.sap/sap/bc/sec/oauth2/token");
  destination("sf-odata", "SF_ODATA_V2", "odata", "https://api55.sapsf.eu/odata/v2", "sf-prd", "basic", "integration@uimdemo");
  destination("btp-automation", "BTP_AUTOMATION", "restApi", "https://automation.uim-demo.example/api/v1", "btp-eu10",
    "noAuthentication");

  void scenario(string id, string name, string category, string source, string target, string description, string[] prerequisites) {
    ScenarioInput i;
    i.name = name;
    i.category = category;
    i.sourceSystemType = source;
    i.targetSystemType = target;
    i.description = description;
    i.prerequisites = prerequisites;
    ports.scenarios.create(createCommand(t, actor, id, i));
    r.scenarios++;
  }

  void task(string scenarioId, string id, int seq, string name, string type, string role, string instructions,
    string priority = "medium", bool needsSource = false, bool needsTarget = false, string destination = "",
    string endpoint = "", string payload = "", int minutes = 15) {
    ScenarioTaskInput i;
    i.scenarioId = scenarioId;
    i.sequenceNumber = seq;
    i.name = name;
    i.taskType = type;
    i.assignedRole = role;
    i.instructions = instructions;
    i.priority = priority;
    i.requiresSourceSystem = needsSource;
    i.requiresTargetSystem = needsTarget;
    i.destinationId = destination;
    i.automationEndpoint = endpoint;
    i.automationPayload = payload;
    i.estimatedMinutes = minutes;
    ports.scenarioTasks.create(createCommand(t, actor, id, i));
    r.scenarioTasks++;
  }

  // ── 1: SuccessFactors Employee Central → S/4HANA Cloud ──────────────────
  scenario("sf-s4-employee", "Integrate SAP SuccessFactors Employee Central with SAP S/4HANA Cloud", "recruitToRetire",
    "sapSuccessFactors", "sapS4HanaCloud", "Replicate employees and organisational data from Employee Central to "
    ~ "S/4HANA Cloud (business partners, cost centers).", [
      "Administrator access to both systems", "SAP BTP subaccount with Cloud Integration"
    ]);
  task("sf-s4-employee", "sf-s4-prereq", 10, "Review prerequisites", "manual", "Integration Expert",
    "Check the prerequisites of the scenario and the system releases.", "medium", false, false, "", "", "", 20);
  task("sf-s4-employee", "sf-s4-comm", 20, "Create communication arrangement SAP_COM_0001", "manual", "S/4HANA Administrator",
    "In S/4HANA Cloud: Communication Arrangements → New → SAP_COM_0001; create a communication user.", "high", false, true,
    "", "", "", 30);
  task("sf-s4-employee", "sf-s4-perm", 20, "Grant OData API permissions in SuccessFactors", "manual",
    "SuccessFactors Administrator", "Admin Center → Manage Permission Roles: grant Employee Central API access to the "
    ~ "integration user.", "high", true, false, "", "", "", 30);
  task("sf-s4-employee", "sf-s4-dest", 30, "Create the destinations in the BTP subaccount", "automated", "Integration Expert",
    "Created automatically through the BTP automation API.", "medium", true, true, "btp-automation", "/destinations",
    `{"names":["SF_ODATA_V2","S4_BUSINESS_PARTNER"]}`, 5);
  task("sf-s4-employee", "sf-s4-golive", 40, "Approve go-live", "approval", "Integration Lead",
    "Confirm the test replication of 10 employees and approve the go-live.", "critical", false, false, "", "", "", 15);
  task("sf-s4-employee", "sf-s4-notify", 50, "Notify HR business partners", "notification", "HR Business Partner",
    "The employee replication is live.", "low");
  ports.scenarios.activate(t, ScenarioId("sf-s4-employee"), actor);

  // ── 2: S/4HANA Cloud → Ariba procurement ────────────────────────────────
  scenario("s4-ariba-procurement", "Connect SAP S/4HANA Cloud with SAP Ariba Procurement", "sourceToPay", "sapS4HanaCloud",
    "sapAriba", "Purchase orders, order confirmations and invoices between S/4HANA Cloud and Ariba Network.",
    ["Ariba realm with integration toolkit", "S/4HANA communication scenario SAP_COM_0A00"]);
  task("s4-ariba-procurement", "s4ar-realm", 10, "Configure the Ariba realm", "manual", "Ariba Administrator",
    "Enable cXML integration and create the shared secret.", "high", false, true, "", "", "", 45);
  task("s4-ariba-procurement", "s4ar-comm", 20, "Set up communication scenario SAP_COM_0A00", "manual", "S/4HANA Administrator",
    "Create the communication system and arrangement for Ariba Network.", "high", true, false, "", "", "", 30);
  task("s4-ariba-procurement", "s4ar-test", 30, "Send a test purchase order", "automated", "Integration Expert",
    "Posts a test purchase order through the S/4HANA API.", "medium", true, false, "s4-bp", "/A_BusinessPartner?$top=1", "", 5);
  task("s4-ariba-procurement", "s4ar-approve", 40, "Approve the integration", "approval", "Procurement Lead",
    "Check the test order in Ariba Network and approve.", "high");
  ports.scenarios.activate(t, ScenarioId("s4-ariba-procurement"), actor);

  // ── 3: draft ────────────────────────────────────────────────────────────
  scenario("btp-event-mesh", "Set up SAP Event Mesh for S/4HANA business events", "btpServices", "sapS4HanaCloud", "sapBtp",
    "Publish business partner events from S/4HANA Cloud to SAP Event Mesh.", ["Event Mesh service instance"]);
  task("btp-event-mesh", "em-channel", 10, "Create the event channel in S/4HANA", "manual", "S/4HANA Administrator",
    "Enterprise Event Enablement → Configure Channel Binding.", "medium", true, false);
  task("btp-event-mesh", "em-queue", 20, "Create queue and subscription", "manual", "Integration Expert",
    "Event Mesh → Queues → Create; subscribe to sap/s4/beh/businesspartner/v1/*.", "medium", false, true);

  // ── workflows ───────────────────────────────────────────────────────────
  CreateWorkflowCommand w1;
  w1.tenantId = t;
  w1.actor = actor;
  w1.id = "wf-employee-wave1";
  w1.scenarioId = "sf-s4-employee";
  w1.name = "Employee Central → S/4HANA (wave 1)";
  w1.sourceSystemId = "sf-prd";
  w1.targetSystemId = "s4-cloud-prd";
  w1.start = true;
  auto wf1 = ports.workflows.create(w1);
  r.workflows++;
  auto tasks = ports.tasks.listOf(t, wf1.id);
  r.workflowTasks += tasks.length;
  ports.tasks.start(t, tasks[0].id, actor);
  ports.tasks.complete(t, tasks[0].id, "Releases 2508 / 1H 2026 — prerequisites fulfilled", actor);
  ports.tasks.start(t, tasks[1].id, actor);

  CreateWorkflowCommand w2;
  w2.tenantId = t;
  w2.actor = actor;
  w2.id = "wf-procurement";
  w2.scenarioId = "s4-ariba-procurement";
  w2.name = "Procurement go-live";
  w2.sourceSystemId = "s4-cloud-prd";
  w2.targetSystemId = "ariba-test";
  auto wf2 = ports.workflows.create(w2);
  r.workflows++;
  r.workflowTasks += ports.tasks.listOf(t, wf2.id).length;
  return r;
}
