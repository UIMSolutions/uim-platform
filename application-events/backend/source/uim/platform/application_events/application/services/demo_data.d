/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo content of an empty tenant: one formation with S/4HANA Cloud,
/// SuccessFactors, a CRM extension and an analytics consumer; business
/// partner, sales order and employee event types; a webhook, a queue and an
/// unreachable webhook; three subscriptions (one with filters) and a few
/// published events — delivered, queued, filtered and retrying.
module uim.platform.application_events.application.services.demo_data;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

enum string bpCreated = "sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1";
enum string bpChanged = "sap.s4.beh.businesspartner.v1.BusinessPartner.Changed.v1";
enum string orderCreated = "sap.s4.beh.salesorder.v1.SalesOrder.Created.v1";
enum string employeeHired = "sap.sf.employee.v1.Employee.Hired.v1";

SeedResult seedDemoData(AehPorts ports, TenantId t, UserId actor) {
  if (ports.systems.list(t).length > 0 || ports.formations.list(t).length > 0)
    throw AehException.ruleViolation("Demo content needs an empty tenant (systems or formations exist)");
  SeedResult r;

  FormationInput f;
  f.name = "Customer Landscape";
  f.description = "S/4HANA Cloud, SuccessFactors and the side-by-side extensions on SAP BTP";
  f.globalAccountId = "ga-demo";
  ports.formations.create(createCommand(t, actor, "landscape", f));
  r.formations++;

  void system(string id, string name, string type, string url, string description) {
    SystemInput s;
    s.name = name;
    s.systemType = type;
    s.systemUrl = url;
    s.description = description;
    s.formationId = "landscape";
    ports.systems.create(createCommand(t, actor, id, s));
    r.systems++;
  }

  system("s4", "S/4HANA Cloud", "both", "https://my-s4.s4hana.cloud.sap", "ERP: business partners and sales orders");
  system("sf", "SuccessFactors", "producer", "https://sf.successfactors.eu", "HR: employee life cycle");
  system("crm", "CRM Extension", "consumer", "https://crm-ext.cfapps.eu10.hana.ondemand.com", "Side-by-side extension on SAP BTP");
  system("analytics", "Analytics", "consumer", "", "Reads sales orders from a queue");

  void topic(string id, string type, string title, string category, string owner) {
    TopicInput i;
    i.eventType = type;
    i.title = title;
    i.category = category;
    i.ownerSystemId = owner;
    i.description = title ~ " (CloudEvents, JSON payload)";
    ports.topics.create(createCommand(t, actor, id, i));
    r.topics++;
  }

  topic("bp-created", bpCreated, "Business Partner Created", "Business Partner", "s4");
  topic("bp-changed", bpChanged, "Business Partner Changed", "Business Partner", "s4");
  topic("order-created", orderCreated, "Sales Order Created", "Sales Order", "s4");
  topic("employee-hired", employeeHired, "Employee Hired", "Employee", "sf");

  void channel(string id, string name, string type, string endpoint, string consumer) {
    ChannelInput c;
    c.name = name;
    c.channelType = type;
    c.endpoint = endpoint;
    c.consumerSystemId = consumer;
    ports.channels.create(createCommand(t, actor, id, c));
    r.channels++;
  }

  channel("crm-webhook", "CRM Webhook", "webhook", "https://crm-ext.cfapps.eu10.hana.ondemand.com/events", "crm");
  channel("crm-onboarding", "CRM Onboarding Webhook", "webhook", "https://onboarding.unreachable.invalid/hook", "crm");
  channel("analytics-queue", "Analytics Queue", "queue", "", "analytics");

  void subscription(string id, string name, string producer, string consumer, string type, string channelId, int retries) {
    SubscriptionInput s;
    s.name = name;
    s.producerSystemId = producer;
    s.consumerSystemId = consumer;
    s.eventType = type;
    s.channelId = channelId;
    s.maxRetries = retries;
    s.retryBackoffSeconds = 30;
    ports.subscriptions.create(createCommand(t, actor, id, s));
    r.subscriptions++;
  }

  subscription("bp-to-crm", "Business partners (DACH) to CRM", "s4", "crm", "sap.s4.beh.businesspartner.v1.*",
    "crm-webhook", 5);
  subscription("orders-to-analytics", "Sales orders to Analytics", "s4", "analytics", orderCreated, "analytics-queue", 5);
  subscription("hires-to-crm", "New hires to CRM onboarding", "sf", "crm", employeeHired, "crm-onboarding", 2);

  FilterInput dach;
  dach.subscriptionId = "bp-to-crm";
  dach.attribute = "data.country";
  dach.operator_ = "oneOf";
  dach.value = "DE, AT, CH";
  dach.description = "DACH business partners only";
  ports.filters.create(createCommand(t, actor, "bp-dach", dach));
  FilterInput blocked;
  blocked.subscriptionId = "bp-to-crm";
  blocked.filterType = "exclude";
  blocked.attribute = "data.blocked";
  blocked.value = "true";
  blocked.description = "no blocked partners";
  ports.filters.create(createCommand(t, actor, "bp-not-blocked", blocked));
  r.filters += 2;

  void publish(string type, string source, Json data, string subject) {
    auto p = ports.publishing.publish(publishRequest(t, actor, type, source, data, subject));
    r.events++;
    r.messages += p.routed;
  }

  publish(bpCreated, "s4", Json(["businessPartner": Json("1000042"), "name": Json("Müller GmbH"), "country": Json("DE")]),
    "BusinessPartner/1000042");
  publish(bpCreated, "s4", Json(["businessPartner": Json("1000043"), "name": Json("Acme Inc."), "country": Json("US")]),
    "BusinessPartner/1000043");
  publish(bpChanged, "s4", Json(["businessPartner": Json("1000042"), "country": Json("AT"), "changed": Json([Json("address")])]),
    "BusinessPartner/1000042");
  publish(orderCreated, "s4", Json(["salesOrder": Json("4711"), "soldToParty": Json("1000042"), "netAmount": Json(1250.5),
      "currency": Json("EUR")]), "SalesOrder/4711");
  publish(employeeHired, "sf", Json(["userId": Json("ada.lovelace"), "startDate": Json("2026-12-01"), "department": Json("R&D")]),
    "Employee/ada.lovelace");
  return r;
}
