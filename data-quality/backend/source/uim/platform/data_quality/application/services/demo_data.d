/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo content for an empty tenant: a "countries" reference dataset, a
/// "customers" dataset with typical defects (malformed e-mails, country
/// names instead of codes, duplicates, missing values, …), "suppliers",
/// validation and cleansing rules, cleansed addresses — validated,
/// profiled and checked for duplicates. A pending cleansing job is left
/// for the user to run.
module uim.platform.data_quality.application.services.demo_data;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct SeedResult {
  size_t datasets;
  size_t records;
  size_t validationRules;
  size_t cleansingRules;
  size_t addresses;
  size_t violations;
  size_t matchGroups;
  size_t cleansingJobs;
}

private FieldValue[] row(string[] pairs...) {
  FieldValue[] fields;
  for (size_t i = 0; i + 1 < pairs.length; i += 2)
    fields ~= FieldValue(pairs[i], pairs[i + 1]);
  return fields;
}

SeedResult seedDemoData(DqPorts ports, TenantId t, UserId actor) {
  if (ports.datasets.listDatasets(t).length > 0)
    throw DataQualityException.conflict("Tenant '" ~ t.value ~ "' already has datasets; demo data is only created in an empty tenant");
  SeedResult s;

  void dataset(string id, string name, string category, string description, InlineRecord[] records) {
    CreateDatasetRequest d;
    d.tenantId = t;
    d.actor = actor;
    d.id = id;
    d.name = name;
    d.category = category;
    d.description = description;
    ports.datasets.createDataset(d);
    ImportRecordsRequest r;
    r.tenantId = t;
    r.actor = actor;
    r.datasetId = DatasetId(id);
    r.records = records;
    r.validate = false;
    s.records += ports.records.importRecords(r).created;
    s.datasets++;
  }

  // ── reference data ──────────────────────────────────────────────────────
  InlineRecord[] countries;
  foreach (c; [["DE", "Germany"], ["AT", "Austria"], ["CH", "Switzerland"], ["FR", "France"], ["NL", "Netherlands"],
      ["GB", "United Kingdom"], ["US", "United States"], ["IT", "Italy"], ["ES", "Spain"]])
    countries ~= InlineRecord(c[0].toLower, row("code", c[0], "name", c[1]));
  dataset("countries", "Countries", "reference data", "ISO 3166 alpha-2 country codes", countries);

  // ── customers (with typical defects) ────────────────────────────────────
  dataset("customers", "Customers", "master data", "Customer master data imported from the legacy CRM", [
    InlineRecord("c-1001", row("name", "Jürgen Müller", "email", "j.mueller@example.de", "phone", "+49 30 1234567", "city", "Berlin",
        "postalCode", "10115", "country", "DE", "age", "52", "status", "active")),
    InlineRecord("c-1002", row("name", "Juergen Mueller", "email", "J.Mueller@Example.de ", "phone", "030/1234567", "city", "berlin",
        "postalCode", "10115", "country", "Germany", "age", "52", "status", "active")),
    InlineRecord("c-1003", row("name", "Anna Schmidt", "email", "anna.schmidt@example", "phone", "+49 89 765432", "city", "München",
        "postalCode", "80331", "country", "DE", "age", "34", "status", "active")),
    InlineRecord("c-1004", row("name", "", "email", "info@acme.example.com", "phone", "+1 212 555 0100", "city", "New York",
        "postalCode", "10001", "country", "US", "age", "", "status", "prospect")),
    InlineRecord("c-1005", row("name", "Marie Dubois", "email", "marie.dubois@example.fr", "phone", "+33 1 42 68 53 00",
        "city", "paris", "postalCode", "75001", "country", "France", "age", "29", "status", "Active")),
    InlineRecord("c-1006", row("name", "Peter  Gruber", "email", "p.gruber@example.at", "phone", "+43 1 5134567", "city", "Wien",
        "postalCode", "1010", "country", "AT", "age", "17", "status", "active")),
    InlineRecord("c-1007", row("name", "Lena Vogel", "email", "", "phone", "", "city", "Hamburg", "postalCode", "2009",
        "country", "DE", "age", "41", "status", "")),
    InlineRecord("c-1008", row("name", "John Smith", "email", "john.smith@example.co.uk", "phone", "+44 20 7946 0958",
        "city", "London", "postalCode", "SW1A 1AA", "country", "GB", "age", "63", "status", "blocked")),
    InlineRecord("c-1009", row("name", "Jon Smith", "email", "john.smith@example.co.uk", "phone", "+44 20 7946 0958",
        "city", "London", "postalCode", "SW1A 1AA", "country", "UK", "age", "63", "status", "active")),
    InlineRecord("c-1010", row("name", "Sofia Rossi", "email", "sofia.rossi@example.it", "phone", "+39 06 6982", "city", "Roma",
        "postalCode", "00120", "country", "IT", "age", "131", "status", "active")),
    InlineRecord("c-1011", row("name", "Jan de Vries", "email", "jan@devries.example.nl", "phone", "+31 20 555 1234",
        "city", "Amsterdam", "postalCode", "1012 AB", "country", "Netherlands", "age", "45", "status", "active")),
    InlineRecord("c-1012", row("name", "Carlos García", "email", "carlos.garcia@example.es", "phone", "+34 91 123 45 67",
        "city", "Madrid", "postalCode", "28013", "country", "ES", "age", "38", "status", "prospect"))
  ]);

  // ── suppliers ───────────────────────────────────────────────────────────
  dataset("suppliers", "Suppliers", "master data", "Supplier master data of the procurement system", [
    InlineRecord("s-01", row("name", "Nordstahl GmbH", "vatId", "DE123456789", "country", "DE", "email", "einkauf@nordstahl.example")),
    InlineRecord("s-02", row("name", "Alpenholz AG", "vatId", "ATU12345678", "country", "AT", "email", "office@alpenholz.example")),
    InlineRecord("s-03", row("name", "Logistique Lumière", "vatId", "FR-1234", "country", "FR", "email", "contact@lumiere.example")),
    InlineRecord("s-04", row("name", "", "vatId", "NL123456789B01", "country", "NL", "email", "sales@polder.example")),
    InlineRecord("s-05", row("name", "Thames Components Ltd", "vatId", "GB123456789", "country", "GB", "email", "orders@thames.example"))
  ]);

  // ── validation rules ────────────────────────────────────────────────────
  void validationRule(string id, string name, string pattern, string field, string type, string severity, string category,
    int priority, scope void delegate(ref ValidationRuleInput) @safe configure = null) {
    CreateValidationRuleRequest r;
    r.tenantId = t;
    r.actor = actor;
    r.id = id;
    r.rule.name = name;
    r.rule.datasetPattern = pattern;
    r.rule.fieldName = field;
    r.rule.ruleType = type;
    r.rule.severity = severity;
    r.rule.status = "active";
    r.rule.category = category;
    r.rule.priority = priority;
    if (configure !is null)
      configure(r.rule);
    ports.validationRules.createValidationRule(r);
    s.validationRules++;
  }

  validationRule("name-required", "Name is required", "", "name", "required", "critical", "identity", 10);
  validationRule("email-required", "E-mail is required", "customers", "email", "required", "error", "contact", 20);
  validationRule("email-format", "E-mail format", "", "email", "format", "error", "contact", 21,
    (ref ValidationRuleInput i) { i.pattern = `^[^@\s]+@[^@\s]+\.[A-Za-z]{2,}$`; });
  validationRule("email-unique", "E-mail is unique", "customers", "email", "unique", "warning", "contact", 22,
    (ref ValidationRuleInput i) { i.caseSensitive = false; });
  validationRule("country-iso", "Country is an ISO code", "", "country", "referenceData", "error", "address", 30,
    (ref ValidationRuleInput i) { i.referenceDataset = "countries"; i.referenceField = "code"; });
  validationRule("postal-de", "German postal codes have 5 digits", "customers", "postalCode", "custom", "error", "address", 31,
    (ref ValidationRuleInput i) { i.expression = "country == DE => postalCode matches ^[0-9]{5}$"; });
  validationRule("age-range", "Age between 18 and 120", "customers", "age", "range", "warning", "profile", 40,
    (ref ValidationRuleInput i) { i.minValue = "18"; i.maxValue = "120"; });
  validationRule("status-values", "Known customer status", "customers", "status", "enumeration", "warning", "profile", 41,
    (ref ValidationRuleInput i) { i.allowedValues = ["active", "blocked", "prospect"]; });
  validationRule("phone-format", "Phone in international format", "customers", "phone", "format", "info", "contact", 50,
    (ref ValidationRuleInput i) { i.pattern = `^\+[1-9][0-9 ]{6,18}$`; });
  validationRule("vat-format", "VAT id format", "suppliers", "vatId", "format", "error", "tax", 60,
    (ref ValidationRuleInput i) { i.pattern = `^[A-Z]{2}[0-9A-Z]{8,12}$`; });

  // ── cleansing rules ─────────────────────────────────────────────────────
  void cleansingRule(string id, string name, string field, string action, int priority,
    scope void delegate(ref CleansingRuleInput) @safe configure = null) {
    CreateCleansingRuleRequest r;
    r.tenantId = t;
    r.actor = actor;
    r.id = id;
    r.rule.name = name;
    r.rule.datasetPattern = "customers";
    r.rule.fieldName = field;
    r.rule.action = action;
    r.rule.status = "active";
    r.rule.priority = priority;
    if (configure !is null)
      configure(r.rule);
    ports.cleansingRules.createCleansingRule(r);
    s.cleansingRules++;
  }

  cleansingRule("email-trim", "Trim e-mail", "email", "trim", 10);
  cleansingRule("email-lower", "Lower case e-mail", "email", "lowerCase", 11);
  cleansingRule("name-spaces", "Collapse blanks in names", "name", "collapseWhitespace", 20);
  cleansingRule("city-case", "Title case cities", "city", "titleCase", 30);
  cleansingRule("country-iso", "Country names to ISO codes", "country", "standardizeCountry", 40);
  cleansingRule("status-lower", "Lower case status", "status", "lowerCase", 50);
  cleansingRule("status-default", "Default status", "status", "defaultValue", 51, (ref CleansingRuleInput i) {
    i.defaultValue = "prospect";
  });
  cleansingRule("country-name", "Country name from reference data", "countryName", "enrich", 60, (ref CleansingRuleInput i) {
    i.lookupDataset = "countries";
    i.lookupKeyField = "code";
    i.lookupValueField = "name";
    i.sourceField = "country";
  });

  // ── analyses ────────────────────────────────────────────────────────────
  foreach (id; ["countries", "customers", "suppliers"]) {
    s.violations += ports.validation.validateDataset(t, DatasetId(id), actor).violations;
    ports.profiling.profileDataset(t, DatasetId(id), actor);
  }
  DetectDuplicatesRequest d;
  d.tenantId = t;
  d.actor = actor;
  d.datasetId = DatasetId("customers");
  d.matchFields = ["name", "city"];
  d.strategy = "composite";
  d.threshold = 85;
  s.matchGroups = ports.duplicates.detectDuplicates(d).groups;

  CreateCleansingJobRequest job;
  job.tenantId = t;
  job.actor = actor;
  job.datasetId = DatasetId("customers");
  ports.cleansingJobs.createCleansingJob(job);
  s.cleansingJobs++;

  // ── addresses ───────────────────────────────────────────────────────────
  foreach (a; [
      AddressInput("Unter den Linden 77", "", "berlin", "", "10117", "Deutschland"),
      AddressInput("Hauptstr. 12", "2. OG", "münchen", "bayern", "8033", "Germany"),
      AddressInput("1600 Pennsylvania Ave NW", "", "washington", "dc", "205000001", "USA"),
      AddressInput("10 Downing Street", "", "London", "", "SW1A 2AA", "GB"),
      AddressInput("Rue de Rivoli 99", "", "Paris", "", "7500", "France")
    ]) {
    CleanseAddressRequest r;
    r.tenantId = t;
    r.actor = actor;
    r.input = a;
    ports.addresses.cleanseAddress(r);
    s.addresses++;
  }
  return s;
}
