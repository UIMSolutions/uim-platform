/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo content: an order-to-cash landscape on SAP BTP with one block of
/// every kind, realizations, a gap (analytics), an orphan (Kyma) and a
/// phase-out risk (legacy CRM still serving customer service). Created
/// through the use cases, so every rule applies.
module uim.platform.architecture.application.services.demo_data;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class DemoDataSeeder : ISeedDemoData {
  protected IManageBuildingBlocks blocks;
  protected IManageRelationships relationships;

  this(IManageBuildingBlocks blocks, IManageRelationships relationships) {
    this.blocks = blocks;
    this.relationships = relationships;
  }

  SeedResult seed(TenantId t, UserId actor) {
    if (blocks.listBlocks(t).length > 0)
      throw ArchitectureException.conflict("Tenant '" ~ t.value ~ "' already contains building blocks");
    SeedResult result;

    void block(string id, string kind, string element, string name, string status, string owner, string description,
      string[string] extra = null, string[] tags = null) {
      CreateBlockRequest r;
      r.tenantId = t;
      r.actor = actor;
      r.id = id;
      r.kind = kind;
      r.values.name = name;
      r.values.elementType = element;
      r.values.status = status;
      r.values.owner = owner;
      r.values.description = description;
      if (tags.length)
        r.values.tags = tags;
      foreach (k, v; extra) {
        switch (k) {
        case "capability":
          r.values.capability = v;
          break;
        case "realizes":
          r.values.realizesId = v;
          break;
        case "vendor":
          r.values.vendor = v;
          break;
        case "version":
          r.values.versionLabel = v;
          break;
        case "classification":
          r.values.dataClassification = v;
          break;
        case "dataOwner":
          r.values.dataOwner = v;
          break;
        case "source":
          r.values.sourceSystem = v;
          break;
        case "factSheet":
          r.values.factSheetType = v;
          break;
        case "viewpoint":
          r.values.viewpoint = v;
          break;
        case "interfaces":
          r.values.interfaces = v.split(",").map!(s => s.strip).array;
          break;
        case "validUntil":
          r.values.validUntil = v;
          break;
        default:
          assert(0, k);
        }
      }
      blocks.createBlock(r);
      result.blocks++;
    }

    void relate(string type, string source, string target, string description) {
      CreateRelationshipRequest r;
      r.tenantId = t;
      r.actor = actor;
      r.type = type;
      r.sourceId = source;
      r.targetId = target;
      r.description = description;
      relationships.createRelationship(r);
      result.relationships++;
    }

    // ── Business ────────────────────────────────────────────────────────
    block("bbb-order-to-cash", "business", "BusinessProcess", "Order to Cash", "active", "sales-operations",
      "End-to-end process from customer order to payment", ["capability": "Sell to customers",
        "viewpoint": "Business Process Cooperation"], ["core", "sales"]);
    block("bbb-order-management", "business", "BusinessFunction", "Order Management", "active", "sales-operations",
      "Capture, validate and fulfil customer orders", ["capability": "Manage orders"], ["sales"]);
    block("bbb-customer-service", "business", "BusinessService", "Customer Service", "active", "customer-care",
      "Answer customer requests across channels", ["capability": "Serve customers"], ["service"]);

    // ── Architecture building blocks ────────────────────────────────────
    block("abb-crm", "architecture", "ApplicationComponent", "Customer Relationship Management", "approved",
      "enterprise-architecture", "Vendor neutral CRM capability: accounts, contacts, opportunities",
      ["capability": "Manage customer relationships", "interfaces": "OData v4, Events"], ["crm", "standard"]);
    block("abb-order-capture", "architecture", "ApplicationService", "Order Capture", "approved", "enterprise-architecture",
      "Order intake API for all sales channels", ["capability": "Capture orders", "interfaces": "REST, OData v4"], ["sales"]);
    block("abb-integration", "architecture", "ApplicationComponent", "Event-driven Integration", "active",
      "enterprise-architecture", "Asynchronous, loosely coupled integration through a message broker",
      ["capability": "Integrate applications", "interfaces": "AMQP, MQTT"], ["integration", "event", "reusable"]);
    block("abb-iam", "architecture", "ApplicationComponent", "Identity and Access Management", "active",
      "security-office", "Authentication, single sign-on and role based authorization",
      ["capability": "Secure access", "interfaces": "OAuth 2.0, SAML 2.0"], ["security"]);
    block("abb-analytics", "architecture", "ApplicationComponent", "Analytics Platform", "proposed",
      "enterprise-architecture", "Self-service analytics on sales and customer data", ["capability": "Analyze business data"],
      ["analytics"]);

    // ── Solution building blocks ────────────────────────────────────────
    block("sbb-sales-cloud", "solution", "ApplicationComponent", "SAP Sales Cloud", "active", "crm-team",
      "SaaS CRM of the sales organization", ["realizes": "abb-crm", "vendor": "SAP", "version": "2611",
        "factSheet": "Application"], ["crm", "saas"]);
    block("sbb-legacy-crm", "solution", "ApplicationComponent", "Legacy CRM", "deprecated", "crm-team",
      "On-premise CRM, replaced by SAP Sales Cloud", ["realizes": "abb-crm", "vendor": "In-house", "version": "4.2",
        "validUntil": "2027-06-30", "factSheet": "Application"], ["crm", "legacy"]);
    block("sbb-order-service", "solution", "ApplicationComponent", "Order Service", "inDevelopment", "order-team",
      "Order capture microservice (D / vibe.d) on SAP BTP", ["realizes": "abb-order-capture", "vendor": "UIM Platform",
        "version": "0.9.0", "interfaces": "OData v4, REST"], ["sales", "microservice"]);
    block("sbb-event-mesh", "solution", "ApplicationComponent", "SAP Integration Suite, Advanced Event Mesh", "active",
      "integration-team", "Managed event broker", ["realizes": "abb-integration", "vendor": "SAP", "factSheet": "ITComponent"],
      ["integration", "event"]);
    block("sbb-xsuaa", "solution", "ApplicationComponent", "SAP Authorization and Trust Management", "active",
      "security-office", "XSUAA: OAuth 2.0 authorization server of SAP BTP", ["realizes": "abb-iam", "vendor": "SAP"],
      ["security"]);

    // ── Data building blocks ────────────────────────────────────────────
    block("dbb-customer", "data", "DataObject", "Customer", "active", "data-office", "Customer master data",
      ["classification": "confidential", "dataOwner": "Head of Sales", "source": "SAP Sales Cloud",
        "factSheet": "DataObject"], ["master-data", "gdpr"]);
    block("dbb-sales-order", "data", "DataObject", "Sales Order", "active", "data-office", "Customer orders and items",
      ["classification": "internal", "dataOwner": "Head of Sales Operations", "source": "Order Service"], ["transactional"]);

    // ── Technology building blocks ──────────────────────────────────────
    block("tbb-btp-cf", "technology", "Node", "SAP BTP, Cloud Foundry Runtime", "active", "platform-team",
      "Application runtime of the BTP subaccount", ["vendor": "SAP", "factSheet": "ITComponent"], ["platform", "cloud"]);
    block("tbb-postgres", "technology", "SystemSoftware", "PostgreSQL 16", "active", "platform-team",
      "Relational database (SAP BTP PostgreSQL, hyperscaler option)", ["vendor": "PostgreSQL", "version": "16"],
      ["database"]);
    block("tbb-kyma", "technology", "Node", "SAP BTP, Kyma Runtime", "approved", "platform-team",
      "Managed Kubernetes runtime — evaluated for container workloads", ["vendor": "SAP"], ["platform", "kubernetes"]);

    // ── Relationships ───────────────────────────────────────────────────
    relate("composition", "bbb-order-management", "bbb-order-to-cash", "Order management performs order to cash");
    relate("serving", "bbb-customer-service", "bbb-order-to-cash", "");
    relate("serving", "abb-order-capture", "bbb-order-to-cash", "Order intake for the process");
    relate("serving", "sbb-order-service", "bbb-order-to-cash", "");
    relate("serving", "sbb-sales-cloud", "bbb-customer-service", "Customer 360 for the service desk");
    relate("serving", "sbb-legacy-crm", "bbb-customer-service", "Still used for historic cases");
    relate("access", "sbb-sales-cloud", "dbb-customer", "System of record");
    relate("access", "sbb-order-service", "dbb-sales-order", "Writes orders");
    relate("access", "sbb-order-service", "dbb-customer", "Reads customers");
    relate("flow", "sbb-order-service", "sbb-event-mesh", "OrderCreated events");
    relate("serving", "sbb-event-mesh", "sbb-sales-cloud", "Delivers order events");
    relate("serving", "sbb-xsuaa", "sbb-order-service", "Issues the JWTs");
    relate("serving", "tbb-btp-cf", "sbb-order-service", "Runs the service");
    relate("serving", "tbb-postgres", "sbb-order-service", "Persistence");
    relate("association", "abb-crm", "abb-order-capture", "Orders reference customers");
    return result;
  }
}
