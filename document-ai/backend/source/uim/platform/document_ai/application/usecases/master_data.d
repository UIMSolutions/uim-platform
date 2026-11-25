/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Clients, document types and enrichment data.
///
/// Rules: client names are unique per tenant and document type names per
/// client (case insensitive); references must exist; clients and document
/// types cannot be deleted while they are used.
module uim.platform.document_ai.application.usecases.master_data;

import std.uni : icmp;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class ManageClientsUseCase : ResourceInteractor!(Client, ClientId, ClientInput), IManageClients {
  this(DaiRepositories repos, IClock clock, IDaiEventPublisher events, IDaiUnitOfWork unitOfWork, DaiPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDaiRepository!(Client, ClientId) store() {
    return repos.clients;
  }

  protected override string what() {
    return "Client";
  }

  protected override string eventPrefix() {
    return "client";
  }

  protected override ClientInput toInput(const Client e) {
    ClientInput i;
    i.name = e.name;
    i.description = e.description;
    i.documentQuota = e.documentQuota;
    i.dataFeedbackEnabled = e.dataFeedbackEnabled;
    return i;
  }

  protected override void fromInput(TenantId t, ref Client e, ClientInput i, bool creating) {
    e.name = i.name.strip;
    foreach (other; repos.clients.findAll(t))
      if (other.id != e.id && icmp(other.name, e.name) == 0)
        throw DaiException.conflict("A client named '" ~ e.name ~ "' already exists ('" ~ other.id.value ~ "')");
    e.description = i.description.strip;
    e.documentQuota = i.documentQuota;
    e.dataFeedbackEnabled = i.dataFeedbackEnabled;
  }

  protected override void beforeRemove(TenantId t, const Client e, UserId actor) {
    auto what = "Client '" ~ e.name ~ "'";
    requireUnused(what, repos.documents.countByReference(t, "clientId", e.id.value), "documents");
    requireUnused(what, repos.schemas.countByReference(t, "clientId", e.id.value), "schemas");
    requireUnused(what, repos.documentTypes.countByReference(t, "clientId", e.id.value), "document types");
    requireUnused(what, repos.templates.countByReference(t, "clientId", e.id.value), "templates");
    requireUnused(what, repos.enrichmentData.countByReference(t, "clientId", e.id.value), "enrichment records");
    requireUnused(what, repos.trainingJobs.countByReference(t, "clientId", e.id.value), "training jobs");
  }

  long[string] documentCounts(TenantId t) {
    long[string] counts;
    foreach (d; repos.documents.findAll(t))
      if (!d.clientId.isNull)
        counts[d.clientId.value]++;
    return counts;
  }
}

class ManageDocumentTypesUseCase : ResourceInteractor!(DocumentType, DocumentTypeId, DocumentTypeInput), IManageDocumentTypes {
  this(DaiRepositories repos, IClock clock, IDaiEventPublisher events, IDaiUnitOfWork unitOfWork, DaiPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDaiRepository!(DocumentType, DocumentTypeId) store() {
    return repos.documentTypes;
  }

  protected override string what() {
    return "Document type";
  }

  protected override string eventPrefix() {
    return "documentType";
  }

  protected override DocumentTypeInput toInput(const DocumentType e) {
    DocumentTypeInput i;
    i.clientId = e.clientId.value;
    i.name = e.name;
    i.description = e.description;
    i.category = cast(string) e.category;
    i.defaultSchemaId = e.defaultSchemaId.value;
    i.supportedFileTypes = e.supportedFileTypes.dup;
    return i;
  }

  protected override void fromInput(TenantId t, ref DocumentType e, DocumentTypeInput i, bool creating) {
    e.clientId = ClientId(optionalReference!ClientId(repos.clients, t, i.clientId, "Client"));
    e.name = i.name.strip;
    foreach (other; repos.documentTypes.findAll(t))
      if (other.id != e.id && other.clientId == e.clientId && icmp(other.name, e.name) == 0)
        throw DaiException.conflict("A document type named '" ~ e.name ~ "' already exists ('" ~ other.id.value ~ "')");
    e.description = i.description.strip;
    e.category = parseDomainEnum!DocumentCategory(i.category, "category");
    e.defaultSchemaId = SchemaId(optionalReference!SchemaId(repos.schemas, t, i.defaultSchemaId, "Schema"));
    string[] types;
    foreach (ft; i.supportedFileTypes) {
      auto v = cast(string) parseDomainEnum!FileType(ft, "file type");
      if (!types.canFind(v))
        types ~= v;
    }
    e.supportedFileTypes = types;
  }

  protected override void beforeRemove(TenantId t, const DocumentType e, UserId actor) {
    auto what = "Document type '" ~ e.name ~ "'";
    requireUnused(what, repos.documents.countByReference(t, "documentTypeId", e.id.value), "documents");
    requireUnused(what, repos.schemas.countByReference(t, "documentTypeId", e.id.value), "schemas");
    requireUnused(what, repos.templates.countByReference(t, "documentTypeId", e.id.value), "templates");
    requireUnused(what, repos.trainingJobs.countByReference(t, "documentTypeId", e.id.value), "training jobs");
    // enrichment records of the type become valid for every type
    foreach (rec; repos.enrichmentData.findByReference(t, "documentTypeId", e.id.value)) {
      rec.documentTypeId = DocumentTypeId.init;
      stampUpdated(rec, actor, now);
      repos.enrichmentData.save(rec);
    }
  }
}

class ManageEnrichmentDataUseCase : ResourceInteractor!(EnrichmentData, EnrichmentDataId, EnrichmentDataInput),
IManageEnrichmentData {
  this(DaiRepositories repos, IClock clock, IDaiEventPublisher events, IDaiUnitOfWork unitOfWork, DaiPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDaiRepository!(EnrichmentData, EnrichmentDataId) store() {
    return repos.enrichmentData;
  }

  protected override string what() {
    return "Enrichment record";
  }

  protected override string eventPrefix() {
    return "enrichmentData";
  }

  protected override EnrichmentDataInput toInput(const EnrichmentData e) {
    EnrichmentDataInput i;
    i.clientId = e.clientId.value;
    i.documentTypeId = e.documentTypeId.value;
    i.subtype = cast(string) e.subtype;
    i.externalId = e.externalId;
    i.name = e.name;
    i.description = e.description;
    i.attributes = e.attributes.dup;
    return i;
  }

  protected override void fromInput(TenantId t, ref EnrichmentData e, EnrichmentDataInput i, bool creating) {
    e.clientId = ClientId(optionalReference!ClientId(repos.clients, t, i.clientId, "Client"));
    e.documentTypeId = DocumentTypeId(optionalReference!DocumentTypeId(repos.documentTypes, t, i.documentTypeId, "Document type"));
    e.subtype = parseDomainEnum!EnrichmentSubtype(i.subtype, "subtype");
    e.externalId = i.externalId.strip;
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.attributes = normalizePairs(i.attributes, "Attribute");
  }

  protected override void beforeRemove(TenantId t, const EnrichmentData e, UserId actor) {
    // documents keep their match result but lose the reference
    foreach (d; repos.documents.findByReference(t, "matchedEnrichmentId", e.id.value)) {
      d.matchedEnrichmentId = EnrichmentDataId.init;
      d.matchStatus = MatchStatus.notChecked;
      d.matchScore = 0;
      repos.documents.save(d);
    }
  }
}
