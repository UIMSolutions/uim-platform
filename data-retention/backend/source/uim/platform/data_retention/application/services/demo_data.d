/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo content of an empty tenant, created through the driving ports (so
/// every business rule applies). Reference dates are relative to today,
/// so the data subjects always cover every retention phase:
///
///   Sales Order Processing  contract 1y + 3y, commercial/tax law 1y + 10y (anonymize)
///   Employment              employment contract 6m + 3y, payroll 1y + 6y
///   Marketing               consent 2y, no retention (anonymize)
///   Vendor Management       inactive: legal ground without rules (shows the activation check)
module uim.platform.data_retention.application.services.demo_data;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

SeedResult seedDemoData(DrPorts ports, IClock clock, TenantId t, UserId actor) {
  if (ports.applicationGroups.list(t).length || ports.businessPurposes.list(t).length || ports.dataSubjects.list(t).length)
    throw DataRetentionException.conflict("Tenant '" ~ t.value ~ "' is not empty — demo content is only created in an empty tenant");
  SeedResult r;
  auto now = clock.now;

  void group(string id, string name, string scope_, string[] apps, string description) {
    ports.applicationGroups.create(createCommand(t, actor, id, ApplicationGroupInput(name, description, scope_, apps)));
    r.applicationGroups++;
  }

  void entity(string id, string name, string country, string region) {
    ports.legalEntities.create(createCommand(t, actor, id, LegalEntityInput(name, "", country, region)));
    r.legalEntities++;
  }

  void role(string id, string name, string description) {
    ports.dataSubjectRoles.create(createCommand(t, actor, id, DataSubjectRoleInput(name, description)));
    r.dataSubjectRoles++;
  }

  void purpose(string id, string name, string group, string role, string entity, string description) {
    ports.businessPurposes.create(createCommand(t, actor, id, BusinessPurposeInput(name, description, group, role, entity)));
    r.businessPurposes++;
  }

  void ground(string purpose, string id, string name, string type, string reference, int residence, string residenceUnit,
    int retention, string retentionUnit, string action) {
    ports.legalGrounds.create(createCommand(t, actor, id, LegalGroundInput(purpose, name, "", type, reference)));
    r.legalGrounds++;
    if (residence >= 0) {
      ports.residenceRules.create(createCommand(t, actor, id ~ "-residence", ResidenceRuleInput(purpose, id, residence, residenceUnit)));
      r.residenceRules++;
    }
    if (retention >= 0) {
      ports.retentionRules.create(createCommand(t, actor, id ~ "-retention", RetentionRuleInput(purpose, id, retention,
          retentionUnit, action)));
      r.retentionRules++;
    }
  }

  /// monthsAgo < 0: business ongoing (no reference date)
  void subject(string id, string externalId, string name, string purpose, long monthsAgo, bool hold = false) {
    auto reference = monthsAgo < 0 ? "" : isoDateText(plusMonths(now, -monthsAgo));
    ports.dataSubjects.create(createCommand(t, actor, id, DataSubjectInput(externalId, name, "", "", purpose, "", "", reference)));
    if (hold)
      ports.dataSubjects.setLegalHold(t, DataSubjectId(id), true, "Pending lawsuit LIT-2026-014", actor);
    r.dataSubjects++;
  }

  group("erp", "ERP Sales & Finance", "global", ["S4-SD", "S4-FI", "S4-CO"], "Sales orders, billing and accounting");
  group("hr", "Human Resources", "regional", ["SF-EC", "PAYROLL-DE"], "Employee central and payroll");
  group("crm", "Marketing & CRM", "local", ["C4C", "MKT-CLOUD"], "Campaigns, newsletters and leads");

  entity("de01", "UIM Manufaktur GmbH", "DE", "EMEA");
  entity("us01", "UIM Manufaktur Inc.", "US", "Americas");

  role("customer", "Customer", "Buyers of goods and services");
  role("employee", "Employee", "Current and former employees");
  role("contact", "Marketing Contact", "Newsletter subscribers and leads");
  role("vendor", "Vendor Contact", "Contact persons of suppliers");

  purpose("sales", "Sales Order Processing", "erp", "customer", "de01", "Orders, deliveries, invoices and payments");
  ground("sales", "sales-contract", "Contract performance", "contract", "GDPR Art. 6 (1) b", 1, "years", 3, "years", "delete");
  ground("sales", "sales-tax", "Commercial and tax law retention", "legalObligation", "HGB §257, AO §147", 1, "years", 10,
    "years", "anonymize");
  purpose("employment", "Employment Administration", "hr", "employee", "de01", "Personnel files, time and payroll");
  ground("employment", "emp-contract", "Employment contract", "contract", "GDPR Art. 88, BDSG §26", 6, "months", 3, "years",
    "delete");
  ground("employment", "emp-payroll", "Payroll and social security", "legalObligation", "EStG §41, SGB IV §28f", 1, "years",
    6, "years", "delete");
  purpose("marketing", "Marketing Communication", "crm", "contact", "de01", "Newsletters and campaign tracking");
  ground("marketing", "mkt-consent", "Newsletter consent", "consent", "GDPR Art. 6 (1) a, UWG §7", 2, "years", -1, "", "");
  purpose("vendors", "Vendor Management", "erp", "vendor", "us01", "Supplier contacts (rules not complete yet)");
  ground("vendors", "vendor-contract", "Supplier contract", "contract", "", -1, "", -1, "", "");

  foreach (p; ["sales", "employment", "marketing"])
    ports.businessPurposes.activate(t, BusinessPurposeId(p), actor);

  subject("ds-1001", "C-1001", "Ada Lovelace", "sales", -1); // ongoing business
  subject("ds-1002", "C-1002", "Alan Turing", "sales", 4); // within residence
  subject("ds-1003", "C-1003", "Grace Hopper", "sales", 30); // within retention → due for blocking
  subject("ds-1004", "C-1004", "Edsger Dijkstra", "sales", 60); // within retention (tax law)
  subject("ds-1005", "C-1005", "Barbara Liskov", "sales", 140); // end of retention → anonymize
  subject("ds-1006", "C-1006", "Donald Knuth", "sales", 150, true); // end of retention, legal hold
  subject("ds-2001", "E-2001", "Margaret Hamilton", "employment", 3); // within residence
  subject("ds-2002", "E-2002", "Ken Thompson", "employment", 20); // within retention
  subject("ds-2003", "E-2003", "Dennis Ritchie", "employment", 96); // end of retention
  subject("ds-3001", "M-3001", "Tim Berners-Lee", "marketing", 6); // within residence
  subject("ds-3002", "M-3002", "Radia Perlman", "marketing", 30); // consent expired → destroy
  subject("ds-3003", "M-3003", "Linus Torvalds", "marketing", 40); // consent expired → destroy

  ports.deletionRequests.create(CreateDeletionRequestCommand(t, actor, "dr-1", DataSubjectId("ds-3001"), "delete",
      "Newsletter unsubscribe and erasure request (GDPR Art. 17)"));
  ports.deletionRequests.create(CreateDeletionRequestCommand(t, actor, "dr-2", DataSubjectId("ds-1004"), "delete",
      "Customer asks for erasure (GDPR Art. 17)"));
  r.deletionRequests = 2;

  ports.archivingJobs.create(CreateArchivingJobCommand(t, actor, "job-erp-destruct", ApplicationGroupId("erp"),
      "archiveAndDestruct", false, 0, plusDays(startOfDay(now), 1)));
  ports.archivingJobs.create(CreateArchivingJobCommand(t, actor, "job-crm-dryrun", ApplicationGroupId("crm"), "destruct",
      true, 0, plusDays(startOfDay(now), 7)));
  r.archivingJobs = 2;
  return r;
}
