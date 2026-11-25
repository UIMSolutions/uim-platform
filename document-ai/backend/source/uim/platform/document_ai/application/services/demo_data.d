/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Demo content for an empty tenant (Fiori "Create Demo Content", CLI
/// "seed", POST <api>/demo-data): clients, document types, an invoice, a
/// purchase order and a receipt schema with their fields, a template,
/// supplier master data, extracted and confirmed documents and a training
/// job. Everything goes through the driving ports, so all rules apply.
module uim.platform.document_ai.application.services.demo_data;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

SeedResult seedDemoData(DaiPorts ports, TenantId t, UserId actor) {
  if (ports.schemas.list(t).length > 0 || ports.documents.list(t).length > 0)
    throw DaiException.conflict("Demo content is only created in an empty tenant (it already has schemas or documents)");
  SeedResult r;

  void client(string id, string name, string description, int quota, bool feedback) {
    ClientInput i;
    i.name = name;
    i.description = description;
    i.documentQuota = quota;
    i.dataFeedbackEnabled = feedback;
    ports.clients.create(createCommand(t, actor, id, i));
    r.clients++;
  }

  void schema(string id, string name, string description, string category, string[] languages) {
    SchemaInput i;
    i.name = name;
    i.description = description;
    i.category = category;
    i.supportedLanguages = languages;
    ports.schemas.create(createCommand(t, actor, id, i));
    r.schemas++;
  }

  void field(string schemaId, string scope_, int seq, string name, string label, string type, bool required_,
    string description = "", string defaultValue = "") {
    SchemaFieldInput i;
    i.schemaId = schemaId;
    i.fieldScope = scope_;
    i.sequenceNumber = seq;
    i.name = name;
    i.label = label;
    i.valueType = type;
    i.required = required_;
    i.description = description;
    i.defaultValue = defaultValue;
    ports.schemaFields.create(createCommand(t, actor, "", i));
    r.schemaFields++;
  }

  void documentType(string id, string name, string category, string schemaId, string[] fileTypes) {
    DocumentTypeInput i;
    i.name = name;
    i.description = name ~ " documents";
    i.category = category;
    i.defaultSchemaId = schemaId;
    i.supportedFileTypes = fileTypes;
    ports.documentTypes.create(createCommand(t, actor, id, i));
    r.documentTypes++;
  }

  void supplier(string id, string number, string name, string city) {
    EnrichmentDataInput i;
    i.subtype = "supplier";
    i.externalId = number;
    i.name = name;
    i.description = "Supplier " ~ number;
    i.attributes = ["senderName=" ~ name, "senderCity=" ~ city];
    ports.enrichmentData.create(createCommand(t, actor, id, i));
    r.enrichmentRecords++;
  }

  AiDocument upload(string id, string fileName, string typeId, string clientId, long size, int pages, string[] labels,
    string templateId = "") {
    DocumentInput i;
    i.fileName = fileName;
    i.documentTypeId = typeId;
    i.clientId = clientId;
    i.fileSize = size;
    i.pageCount = pages;
    i.labels = labels;
    i.templateId = templateId;
    auto d = ports.documents.create(createCommand(t, actor, id, i));
    r.documents++;
    return d;
  }

  /// Extract and fill missing required values (as a reviewer would).
  AiDocument extracted(AiDocument d) {
    if (d.status == DocumentStatus.pending)
      d = ports.documents.extract(t, d.id, actor);
    foreach (f; ports.fields.listOf(t, d.id))
      if (f.isMissing)
        ports.fields.correct(t, f.id, demoValue(f.valueType), actor);
    return ports.documents.get(t, d.id);
  }

  // ── master data ─────────────────────────────────────────────────────────
  client("finance", "Finance – Accounts Payable", "Supplier invoices and receipts of the shared service center", 1000, true);
  client("procurement", "Procurement", "Purchase orders and order confirmations", 0, false);

  schema("invoice", "Supplier Invoice", "Header fields and line items of supplier invoices", "invoice", ["en", "de"]);
  field("invoice", "header", 10, "documentNumber", "Invoice Number", "string", true, "The number of the invoice");
  field("invoice", "header", 20, "documentDate", "Invoice Date", "date", true);
  field("invoice", "header", 30, "senderName", "Supplier", "string", true, "Name of the issuing company");
  field("invoice", "header", 40, "senderCity", "Supplier City", "string", false);
  field("invoice", "header", 50, "purchaseOrderNumber", "Purchase Order", "string", false);
  field("invoice", "header", 60, "netAmount", "Net Amount", "number", false);
  field("invoice", "header", 70, "taxAmount", "Tax Amount", "number", false);
  field("invoice", "header", 80, "grossAmount", "Gross Amount", "number", true);
  field("invoice", "header", 90, "currencyCode", "Currency", "currency", true, "ISO 4217 code", "EUR");
  field("invoice", "header", 100, "dueDate", "Due Date", "date", false);
  field("invoice", "lineItem", 10, "description", "Description", "string", false);
  field("invoice", "lineItem", 20, "materialNumber", "Material", "string", false);
  field("invoice", "lineItem", 30, "quantity", "Quantity", "number", false);
  field("invoice", "lineItem", 40, "unitPrice", "Unit Price", "number", false);
  field("invoice", "lineItem", 50, "netAmount", "Net Amount", "number", false);
  ports.schemas.activate(t, SchemaId("invoice"), actor);

  schema("purchase-order", "Purchase Order", "Purchase orders received from customers", "purchaseOrder", []);
  field("purchase-order", "header", 10, "documentNumber", "Order Number", "string", true);
  field("purchase-order", "header", 20, "documentDate", "Order Date", "date", true);
  field("purchase-order", "header", 30, "senderName", "Customer", "string", true);
  field("purchase-order", "header", 40, "deliveryDate", "Requested Delivery", "date", false);
  field("purchase-order", "header", 50, "grossAmount", "Order Value", "number", false);
  field("purchase-order", "header", 60, "currencyCode", "Currency", "currency", false, "", "EUR");
  field("purchase-order", "lineItem", 10, "materialNumber", "Material", "string", true);
  field("purchase-order", "lineItem", 20, "description", "Description", "string", false);
  field("purchase-order", "lineItem", 30, "quantity", "Quantity", "number", true);
  field("purchase-order", "lineItem", 40, "unitPrice", "Unit Price", "number", false);
  ports.schemas.activate(t, SchemaId("purchase-order"), actor);

  schema("receipt", "Expense Receipt", "Receipts of travel and expense claims (draft)", "receipt", []);
  field("receipt", "header", 10, "merchantName", "Merchant", "string", true);
  field("receipt", "header", 20, "receiptDate", "Date", "date", true);
  field("receipt", "header", 30, "totalAmount", "Total", "number", true);
  field("receipt", "header", 40, "currencyCode", "Currency", "currency", false, "", "EUR");

  documentType("supplier-invoice", "Supplier Invoice", "invoice", "invoice", ["pdf", "png", "jpeg", "tiff"]);
  documentType("purchase-order", "Purchase Order", "purchaseOrder", "purchase-order", ["pdf", "docx", "xlsx"]);
  documentType("receipt", "Expense Receipt", "receipt", "", ["pdf", "png", "jpeg"]);

  TemplateInput tpl;
  tpl.schemaId = "invoice";
  tpl.documentTypeId = "supplier-invoice";
  tpl.clientId = "finance";
  tpl.name = "ACME Corp invoice layout";
  tpl.description = "Two column layout, totals bottom right";
  tpl.senderName = "ACME Corp";
  ports.templates.create(createCommand(t, actor, "acme-invoice", tpl));
  ports.templates.activate(t, TemplateId("acme-invoice"), actor);
  r.templates++;

  supplier("sup-acme", "100042", "ACME Corp", "Berlin");
  supplier("sup-globex", "100077", "Globex GmbH", "Hamburg");
  supplier("sup-initech", "100103", "Initech AG", "Munich");

  // ── documents ───────────────────────────────────────────────────────────
  auto acme1 = extracted(upload("doc-acme-0042", "ACME-INV-2026-0042.pdf", "supplier-invoice", "finance", 182_344, 2,
      ["senderName=ACME Corp", "senderCity=Berlin", "documentNumber=INV-2026-0042"], "acme-invoice"));
  ports.documents.confirm(t, acme1.id, actor);
  auto acme2 = extracted(upload("doc-acme-0043", "ACME-INV-2026-0043.pdf", "supplier-invoice", "finance", 176_001, 1,
      ["senderName=ACME Corp", "senderCity=Berlin", "documentNumber=INV-2026-0043"], "acme-invoice"));
  ports.documents.confirm(t, acme2.id, actor);
  auto globex = extracted(upload("doc-globex-1126", "globex_invoice_11-2026.pdf", "supplier-invoice", "finance", 95_210,
      1, ["senderName=Globex GmbH", "senderCity=Hamburg", "source=email"]));
  foreach (f; ports.fields.listOf(t, globex.id))
    if (f.name == "dueDate" && f.rowIndex == 0)
      ports.fields.correct(t, f.id, "2026-12-26", actor);
  ports.documents.confirm(t, globex.id, actor);
  extracted(upload("doc-scan-0193", "scan_0193.jpg", "supplier-invoice", "finance", 1_204_400, 1, ["source=scanner"]));
  extracted(upload("doc-po-4500012345", "PO-4500012345.pdf", "purchase-order", "procurement", 64_800, 1,
      ["senderName=Initech AG", "documentNumber=4500012345"]));
  upload("doc-initech-0007", "initech-invoice-0007.tiff", "supplier-invoice", "finance", 2_310_000, 3,
    ["senderName=Initech AG", "senderCity=Munich"]);

  TrainingJobInput job;
  job.schemaId = "invoice";
  job.documentTypeId = "supplier-invoice";
  job.name = "Supplier invoice model";
  job.description = "Retrain with the confirmed invoices of Accounts Payable";
  ports.trainingJobs.create(createCommand(t, actor, "train-invoice", job));
  r.trainingJobs++;
  return r;
}

private string demoValue(FieldValueType type) {
  final switch (type) {
  case FieldValueType.text, FieldValueType.address:
    return "n/a";
  case FieldValueType.number:
    return "0";
  case FieldValueType.date:
    return "2026-11-25";
  case FieldValueType.boolean:
    return "false";
  case FieldValueType.currency:
    return "EUR";
  }
}
