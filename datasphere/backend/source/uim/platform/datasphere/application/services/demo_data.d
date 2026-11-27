/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo content of an empty tenant: a SALES space with S/4HANA Cloud, HANA
/// Cloud and an unreachable legacy database; replicated and federated
/// remote tables; an analytical view, a dimension view and a data flow;
/// tasks, a nightly task chain (already run once), a failed replication,
/// a data access control for the DACH region and catalog entries — plus a
/// small HR space.
module uim.platform.datasphere.application.services.demo_data;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

SeedResult seedDemoData(DspPorts ports, TenantId t, UserId actor) {
  if (ports.spaces.list(t).length > 0)
    throw DspException.ruleViolation("Demo content needs an empty tenant (spaces exist)");
  SeedResult r;

  void space(string id, string name, string description, double disk, double memory, int priority) {
    SpaceInput s;
    s.name = name;
    s.description = description;
    s.diskQuotaGiB = disk;
    s.memoryQuotaGiB = memory;
    s.priority = priority;
    s.auditLogEnabled = true;
    ports.spaces.create(createCommand(t, actor, id, s));
    r.spaces++;
  }

  space("SALES", "Sales Analytics", "Orders and customers of S/4HANA Cloud for SAP Analytics Cloud", 20, 4, 6);
  space("HR", "People Analytics", "Head count and hires (SuccessFactors)", 5, 1, 3);

  void member(string spaceId, string user, string name, string role) {
    MemberInput m;
    m.spaceId = spaceId;
    m.userName = user;
    m.displayName = name;
    m.role = role;
    ports.members.create(createCommand(t, actor, spaceId ~ "." ~ user, m));
    r.members++;
  }

  member("SALES", "admin", "Administrator", "administrator");
  member("SALES", "ada", "Ada Lovelace", "modeler");
  member("SALES", "grace", "Grace Hopper", "integrator");
  member("SALES", "bob", "Bob Viewer", "viewer");
  member("HR", "admin", "Administrator", "administrator");

  void connection(string id, string name, string type, string host, int port, string database, string user) {
    ConnectionInput c;
    c.spaceId = "SALES";
    c.name = name;
    c.connectionType = type;
    c.host = host;
    c.port = port;
    c.database = database;
    c.user = user;
    c.password = "demo-secret";
    c.properties = ["encrypt=true"];
    ports.connections.create(createCommand(t, actor, id, c));
    r.connections++;
  }

  connection("S4", "S/4HANA Cloud", "s4hana", "my-s4.s4hana.cloud.sap", 443, "", "DATASPHERE_COMM");
  connection("HANA", "HANA Cloud (Finance)", "hana", "fin.hana.prod-eu10.hanacloud.ondemand.com", 443, "FINANCE", "DSP_READER");
  connection("LEGACY", "Legacy Orders DB", "sql", "orders.unreachable.invalid", 5432, "orders", "reader");
  ports.connections.validateConnection(t, ConnectionId("S4"), actor);
  ports.connections.validateConnection(t, ConnectionId("HANA"), actor);
  ports.connections.validateConnection(t, ConnectionId("LEGACY"), actor);

  void table(string id, string conn, string name, string business, string schema, string obj, string mode, string[] columns) {
    RemoteTableInput i;
    i.spaceId = "SALES";
    i.connectionId = conn;
    i.name = name;
    i.businessName = business;
    i.remoteSchema = schema;
    i.remoteObject = obj;
    i.replicationMode = mode;
    i.columns = columns;
    ports.remoteTables.create(createCommand(t, actor, id, i));
    r.remoteTables++;
  }

  table("orders", "S4", "S4_SALES_ORDERS", "Sales Orders", "SAP", "I_SALESORDER", "scheduled", [
      "SALESORDER:NVARCHAR(10) key", "SOLDTOPARTY:NVARCHAR(10)", "COUNTRY:NVARCHAR(3)", "NETAMOUNT:DECIMAL(15,2)",
      "CURRENCY:NVARCHAR(5)", "CREATEDAT:TIMESTAMP"
    ]);
  table("customers", "S4", "S4_CUSTOMERS", "Customers", "SAP", "I_CUSTOMER", "snapshot", [
      "CUSTOMER:NVARCHAR(10) key", "NAME:NVARCHAR(80)", "COUNTRY:NVARCHAR(3)", "INDUSTRY:NVARCHAR(4)"
    ]);
  table("gl", "HANA", "FIN_GL_ACCOUNTS", "G/L Accounts", "FINANCE", "GL_ACCOUNTS", "remote", [
      "ACCOUNT:NVARCHAR(10) key", "DESCRIPTION:NVARCHAR(60)"
    ]);
  table("legacy", "LEGACY", "LEGACY_ORDERS", "Legacy Orders", "public", "orders", "snapshot", [
      "ID:BIGINT key", "AMOUNT:DOUBLE"
    ]);

  void view(string id, string name, string business, string semantic, string sql, string[] columns, bool exposed) {
    ViewInput v;
    v.spaceId = "SALES";
    v.name = name;
    v.businessName = business;
    v.semantic = semantic;
    v.sqlExpression = sql;
    v.columns = columns;
    v.exposed = exposed;
    ports.views.create(createCommand(t, actor, id, v));
    ports.views.deploy(t, DataViewId(id), actor);
    r.views++;
  }

  view("customers-dim", "V_CUSTOMERS", "Customers", "dimension",
    "SELECT CUSTOMER, NAME, COUNTRY, INDUSTRY FROM S4_CUSTOMERS",
    ["CUSTOMER:NVARCHAR(10) key", "NAME:NVARCHAR(80)", "COUNTRY:NVARCHAR(3)", "INDUSTRY:NVARCHAR(4)"], false);
  view("sales-orders", "V_SALES_ORDERS", "Sales Orders (analytical)", "analyticalDataset",
    "SELECT o.SALESORDER, o.COUNTRY, c.NAME AS CUSTOMERNAME, o.NETAMOUNT, o.CURRENCY\n"
    ~ "FROM S4_SALES_ORDERS o\nLEFT JOIN V_CUSTOMERS c ON c.CUSTOMER = o.SOLDTOPARTY",
    ["SALESORDER:NVARCHAR(10) key", "COUNTRY:NVARCHAR(3)", "CUSTOMERNAME:NVARCHAR(80)", "NETAMOUNT:DECIMAL(15,2)",
      "CURRENCY:NVARCHAR(5)"], true);

  DataFlowInput f;
  f.spaceId = "SALES";
  f.name = "DF_ORDERS_DACH";
  f.businessName = "Orders of the DACH region";
  f.description = "Filters the S/4HANA sales orders to Germany, Austria and Switzerland";
  f.sourceObjects = ["S4_SALES_ORDERS"];
  f.transforms = ["filter: COUNTRY IN ('DE', 'AT', 'CH')", "projection: SALESORDER, COUNTRY, NETAMOUNT, CURRENCY"];
  f.targetTable = "T_ORDERS_DACH";
  f.loadMode = "truncate";
  ports.dataFlows.create(createCommand(t, actor, "orders-dach", f));
  ports.dataFlows.deploy(t, DataFlowId("orders-dach"), actor);
  r.dataFlows++;

  void task(string id, string name, string type, string target, string frequency, int retries) {
    TaskInput i;
    i.spaceId = "SALES";
    i.name = name;
    i.taskType = type;
    i.targetObjectId = target;
    i.frequency = frequency;
    i.maxRetries = retries;
    ports.tasks.create(createCommand(t, actor, id, i));
    r.tasks++;
  }

  task("replicate-orders", "Replicate sales orders", "replication", "orders", "manual", 2);
  task("replicate-customers", "Replicate customers", "replication", "customers", "manual", 1);
  task("load-orders-dach", "Load DACH orders", "dataFlow", "orders-dach", "manual", 0);
  task("persist-sales-orders", "Persist sales orders view", "viewPersistence", "sales-orders", "manual", 0);
  task("replicate-legacy", "Replicate legacy orders", "replication", "legacy", "daily", 1);

  TaskChainInput c;
  c.spaceId = "SALES";
  c.name = "Nightly sales load";
  c.description = "Replicate, transform and persist the sales data every night";
  c.taskIds = ["replicate-orders", "replicate-customers", "load-orders-dach", "persist-sales-orders"];
  c.frequency = "daily";
  ports.taskChains.create(createCommand(t, actor, "nightly", c));
  r.taskChains++;

  AccessControlInput a;
  a.spaceId = "SALES";
  a.name = "DACH sales";
  a.description = "Sales of Germany, Austria and Switzerland";
  a.criteriaColumn = "COUNTRY";
  a.criteriaOperator = "oneOf";
  a.criteriaValues = ["DE", "AT", "CH"];
  a.targetViewIds = ["sales-orders"];
  a.assignedUsers = ["ada", "admin"];
  ports.accessControls.create(createCommand(t, actor, "dach", a));
  r.accessControls++;

  void asset(string id, string name, string business, string type, string source, string quality, string sensitivity,
    string[] tags, string[] terms, string description) {
    CatalogAssetInput i;
    i.spaceId = "SALES";
    i.name = name;
    i.businessName = business;
    i.assetType = type;
    i.sourceObjectId = source;
    i.owner = "ada";
    i.qualityStatus = quality;
    i.sensitivity = sensitivity;
    i.tags = tags;
    i.glossaryTerms = terms;
    i.description = description;
    ports.catalog.create(createCommand(t, actor, id, i));
    r.catalogAssets++;
  }

  asset("asset-sales-orders", "V_SALES_ORDERS", "Sales Orders", "view", "sales-orders", "good", "confidential",
    ["sales", "revenue", "S/4HANA"], ["Net Amount", "Sold-To Party"], "Analytical dataset of all S/4HANA sales orders");
  asset("asset-customers", "V_CUSTOMERS", "Customers", "view", "customers-dim", "excellent", "internal",
    ["master data", "customer"], ["Customer", "Industry"], "Customer master data from S/4HANA");
  asset("asset-orders", "S4_SALES_ORDERS", "Sales Orders (replica)", "remoteTable", "orders", "adequate", "confidential",
    ["sales", "replica"], ["Sales Order"], "Replica of I_SALESORDER");

  // first runs: the nightly chain and the (failing) legacy replication
  ports.taskChains.runChain(t, TaskChainId("nightly"), actor);
  ports.tasks.runTask(t, TaskId("replicate-legacy"), actor);
  r.runs = ports.monitor.listRuns(t).length;
  return r;
}
