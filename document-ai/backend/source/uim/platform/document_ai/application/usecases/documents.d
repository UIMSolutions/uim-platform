/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document processing: upload, extraction, review, confirmation.
///
/// Upload rules: the file type is detected from the name and must be
/// accepted by the document type; the schema (explicit or the default of
/// the document type) must be active and support the language; a template
/// must be active and belong to the schema; the client quota applies.
/// The extraction replaces all values of the document, flags values below
/// the confidence threshold and matches the header values with the
/// enrichment data. Values can be corrected while the document is done;
/// confirming needs every required header value.
module uim.platform.document_ai.application.usecases.documents;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class ProcessDocumentsUseCase : ResourceInteractor!(AiDocument, DocumentId, DocumentInput), IProcessDocuments {
  protected IExtractionEngine engine;

  this(DaiRepositories repos, IClock clock, IDaiEventPublisher events, IDaiUnitOfWork unitOfWork, DaiPolicy policy,
    IExtractionEngine engine) {
    super(repos, clock, events, unitOfWork, policy);
    this.engine = engine;
  }

  protected override IDaiRepository!(AiDocument, DocumentId) store() {
    return repos.documents;
  }

  protected override string what() {
    return "Document";
  }

  protected override string eventPrefix() {
    return "document";
  }

  protected override string[] immutableAttributes() {
    return ["clientId", "fileName", "fileSize", "mimeType"];
  }

  protected override DocumentInput toInput(const AiDocument e) {
    DocumentInput i;
    i.clientId = e.clientId.value;
    i.fileName = e.fileName;
    i.mimeType = e.mimeType;
    i.fileSize = e.fileSize;
    i.pageCount = e.pageCount;
    i.language = e.language;
    i.documentTypeId = e.documentTypeId.value;
    i.schemaId = e.schemaId.value;
    i.templateId = e.templateId.value;
    i.extractionMethod = cast(string) e.extractionMethod;
    i.labels = e.labels.dup;
    return i;
  }

  protected override void beforeUpdate(TenantId t, const AiDocument e) {
    if (isFinal(e.status))
      throw DaiException.ruleViolation("Document '" ~ e.fileName ~ "' is " ~ cast(string) e.status ~ " and cannot be changed");
  }

  protected override void fromInput(TenantId t, ref AiDocument e, DocumentInput i, bool creating) {
    auto before = creating ? AiDocument.init : e;
    e.fileName = i.fileName.strip;
    requireText(e.fileName, "File name");
    e.fileType = detectFileType(e.fileName);
    e.mimeType = i.mimeType.strip.length ? i.mimeType.strip : mimeTypeOf(e.fileType);
    e.fileSize = i.fileSize;
    e.pageCount = i.pageCount;
    e.language = i.language.strip.toLower.length ? i.language.strip.toLower : "en";
    e.labels = normalizePairs(i.labels, "Label");

    if (creating) {
      e.clientId = ClientId(optionalReference!ClientId(repos.clients, t, i.clientId, "Client"));
      if (!e.clientId.isNull) {
        auto client = repos.clients.findById(t, e.clientId);
        auto used = repos.documents.countByReference(t, "clientId", e.clientId.value);
        if (!client.admits(used))
          throw DaiException.ruleViolation(format("The document quota of client '%s' is used up (%d of %d)", client.name,
              used, client.documentQuota));
      }
    }

    DocumentType type;
    e.documentTypeId = DocumentTypeId(i.documentTypeId.strip);
    if (!e.documentTypeId.isNull) {
      type = required(repos.documentTypes.findById(t, e.documentTypeId), "Document type '" ~ e.documentTypeId.value ~ "'");
      if (!type.accepts(e.fileType))
        throw DaiException.ruleViolation("Document type '" ~ type.name ~ "' does not accept " ~ cast(string) e.fileType
            ~ " files (accepted: " ~ type.supportedFileTypes.join(", ") ~ ")");
    }

    auto schemaId = i.schemaId.strip.length ? SchemaId(i.schemaId.strip) : type.defaultSchemaId;
    if (schemaId.isNull)
      throw DaiException.invalid("A schema is required (give schemaId or a document type with a default schema)");
    auto schema = schemaOf(t, schemaId);
    auto schemaChanged = creating || before.schemaId != schemaId;
    if (schemaChanged && !schema.isActive)
      throw DaiException.ruleViolation("Schema '" ~ schema.name ~ "' is " ~ cast(string) schema.status
          ~ " — documents need an active schema");
    if (!schema.supportsLanguage(e.language))
      throw DaiException.ruleViolation("Schema '" ~ schema.name ~ "' does not support the language '" ~ e.language
          ~ "' (supported: " ~ schema.supportedLanguages.join(", ") ~ ")");
    e.schemaId = schemaId;

    e.templateId = TemplateId(i.templateId.strip);
    if (!e.templateId.isNull) {
      auto tpl = required(repos.templates.findById(t, e.templateId), "Template '" ~ e.templateId.value ~ "'");
      if (!tpl.isActive)
        throw DaiException.ruleViolation("Template '" ~ tpl.name ~ "' is not active");
      if (tpl.schemaId != schemaId)
        throw DaiException.ruleViolation("Template '" ~ tpl.name ~ "' belongs to schema '" ~ tpl.schemaId.value
            ~ "', not to '" ~ schemaId.value ~ "'");
    }
    e.extractionMethod = parseDomainEnumOr!ExtractionMethod(i.extractionMethod,
      e.templateId.isNull ? ExtractionMethod.mlModel : ExtractionMethod.templateBased, "extraction method");
    if (e.extractionMethod == ExtractionMethod.templateBased && e.templateId.isNull)
      throw DaiException.invalid("Template based extraction needs a template");

    // a changed extraction setup makes the values outdated
    if (!creating && e.status == DocumentStatus.done && (before.schemaId != e.schemaId || before.templateId != e.templateId
        || before.extractionMethod != e.extractionMethod || before.language != e.language))
      e.status = DocumentStatus.pending;
  }

  protected override AiDocument afterCreate(TenantId t, AiDocument e, UserId actor) {
    emit("document.uploaded", t, e.id.value, Json(["schemaId": Json(e.schemaId.value), "fileType": Json(cast(string) e.fileType)]));
    return policy.processImmediately ? extract(t, e.id, actor) : e;
  }

  protected override void beforeRemove(TenantId t, const AiDocument e, UserId actor) {
    foreach (f; repos.extractedFields.findByReference(t, "documentId", e.id.value))
      repos.extractedFields.removeById(t, f.id);
    foreach (tpl; repos.templates.findAll(t))
      if (tpl.sampleDocumentIds.canFind(e.id.value)) {
        tpl.sampleDocumentIds = tpl.sampleDocumentIds.filter!(s => s != e.id.value).array;
        repos.templates.save(tpl);
      }
  }

  // ── extraction ─────────────────────────────────────────────────────────
  AiDocument extract(TenantId t, DocumentId id, UserId actor) {
    auto doc = get(t, id);
    if (!doc.canExtract)
      throw DaiException.ruleViolation("Document '" ~ doc.fileName ~ "' is " ~ cast(string) doc.status
          ~ " and cannot be extracted again");
    auto schema = schemaOf(t, doc.schemaId);
    if (schema.isDraft)
      throw DaiException.ruleViolation("Schema '" ~ schema.name ~ "' is a draft");

    ExtractionRequest request;
    request.tenantId = t;
    request.document = doc;
    request.schema = schema;
    request.fields = fieldsOf(t, schema.id);
    if (!doc.templateId.isNull)
      request.template_ = repos.templates.findById(t, doc.templateId);
    auto output = engine.extract(request);

    batch(() {
      foreach (old; repos.extractedFields.findByReference(t, "documentId", id.value))
        repos.extractedFields.removeById(t, old.id);
      doc.attempts++;
      doc.processedAt = now;
      if (output.success) {
        auto fields = buildFields(t, doc, request.fields, output.values, actor);
        foreach (f; fields)
          repos.extractedFields.save(f);
        if (output.pageCount > 0)
          doc.pageCount = output.pageCount;
        doc.status = DocumentStatus.done;
        doc.errorMessage = "";
        refreshSummary(t, doc, fields);
      } else {
        doc.status = DocumentStatus.failed;
        doc.errorMessage = output.message.length ? output.message : "The extraction failed";
        doc.overallConfidence = 0;
        doc.extractedFieldCount = doc.lineItemCount = doc.lowConfidenceCount = doc.correctedFieldCount = 0;
        doc.matchStatus = MatchStatus.notChecked;
        doc.matchedEnrichmentId = EnrichmentDataId.init;
        doc.matchScore = 0;
      }
      stampUpdated(doc, actor, now);
      repos.documents.save(doc);
    });
    auto data = Json.emptyObject;
    data["status"] = cast(string) doc.status;
    data["engine"] = engine.mode;
    data["fields"] = doc.extractedFieldCount;
    data["durationMs"] = output.durationMs;
    emit(output.success ? "document.extracted" : "document.failed", t, id.value, data);
    return doc;
  }

  /// Map the engine values onto the schema fields: every header field gets
  /// a value (empty if not found), line item cells exist per extracted row.
  /// Values that do not match their type are kept but marked unsure.
  protected ExtractedField[] buildFields(TenantId t, const AiDocument doc, const SchemaField[] schemaFields,
    const ExtractedValue[] values, UserId actor) {
    ExtractedField[] result;
    ExtractedField make(const SchemaField sf, int row) {
      ExtractedField f;
      stampCreated!(ExtractedField, ExtractedFieldId)(f, t, actor, newResourceId(), nextTime);
      f.documentId = doc.id;
      f.schemaFieldId = sf.id;
      f.fieldScope = sf.fieldScope;
      f.rowIndex = row;
      f.sequenceNumber = sf.sequenceNumber;
      f.name = sf.name;
      f.label = sf.label;
      f.valueType = sf.valueType;
      f.required = sf.required;
      return f;
    }

    void assign(ref ExtractedField f, const SchemaField sf, const ExtractedValue v) {
      f.value = v.value.strip;
      f.confidence = clamp(v.confidence, 0.0, 1.0);
      f.page = v.page > 0 ? v.page : 1;
      f.coordinates = v.coordinates;
      if (f.value.length == 0 && sf.defaultValue.length) {
        f.value = sf.defaultValue;
        f.confidence = min(f.confidence, 0.5);
      }
      if (f.value.length) {
        try
          checkFieldValue(sf.valueType, f.value);
        catch (DocumentAiException)
          f.confidence = min(f.confidence, 0.3);
      }
    }

    foreach (sf; schemaFields) {
      if (sf.fieldScope == FieldScope.header) {
        auto f = make(sf, 0);
        auto found = values.find!(v => v.fieldScope == FieldScope.header && v.name == sf.name);
        if (!found.empty)
          assign(f, sf, found.front);
        else if (sf.defaultValue.length) {
          f.value = sf.defaultValue;
          f.confidence = 0.5;
        }
        result ~= f;
      }
    }
    int[] rows;
    foreach (v; values)
      if (v.fieldScope == FieldScope.lineItem && v.rowIndex > 0 && !rows.canFind(v.rowIndex))
        rows ~= v.rowIndex;
    rows.sort();
    foreach (row; rows)
      foreach (sf; schemaFields)
        if (sf.fieldScope == FieldScope.lineItem) {
          auto f = make(sf, row);
          auto found = values.find!(v => v.fieldScope == FieldScope.lineItem && v.rowIndex == row && v.name == sf.name);
          if (!found.empty)
            assign(f, sf, found.front);
          result ~= f;
        }
    return result;
  }

  AiDocument confirm(TenantId t, DocumentId id, UserId actor) {
    auto doc = get(t, id);
    auto missing = valuesOf(t, id).filter!(f => f.rowIndex == 0 && f.isMissing).map!(f => f.label.length ? f.label : f.name).array;
    if (doc.status == DocumentStatus.done && missing.length)
      throw DaiException.ruleViolation("Document '" ~ doc.fileName ~ "' cannot be confirmed: required values are missing ("
          ~ missing.join(", ") ~ ")");
    doc.confirm(actor.value, now);
    stampUpdated(doc, actor, now);
    repos.documents.save(doc);
    emit("document.confirmed", t, id.value, Json(["corrected": Json(doc.correctedFieldCount)]));
    return doc;
  }

  AiDocument reject(TenantId t, DocumentId id, string reason, UserId actor) {
    auto doc = get(t, id);
    doc.reject(reason, actor.value, now);
    stampUpdated(doc, actor, now);
    repos.documents.save(doc);
    emit("document.rejected", t, id.value);
    return doc;
  }

  ProcessingSummary processPending(TenantId t, UserId actor, size_t max = 0) {
    ProcessingSummary s;
    foreach (doc; repos.documents.findByReference(t, "status", cast(string) DocumentStatus.pending)) {
      if (max > 0 && s.documents >= max)
        break;
      s.documents++;
      try {
        auto r = extract(t, doc.id, actor);
        if (r.status == DocumentStatus.done)
          s.extracted++;
        else {
          s.failed++;
          s.messages ~= doc.fileName ~ ": " ~ r.errorMessage;
        }
      } catch (DocumentAiException e) {
        s.failed++;
        s.messages ~= doc.fileName ~ ": " ~ e.msg;
        doc.status = DocumentStatus.failed;
        doc.errorMessage = e.msg;
        doc.attempts++;
        stampUpdated(doc, actor, now);
        repos.documents.save(doc);
      }
    }
    return s;
  }
}

/// Review of the extracted values (corrections while the document is done).
class ReviewFieldsUseCase : DaiInteractor, IReviewFields {
  this(DaiRepositories repos, IClock clock, IDaiEventPublisher events, IDaiUnitOfWork unitOfWork, DaiPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  ExtractedField get(TenantId t, ExtractedFieldId id) {
    return required(repos.extractedFields.findById(t, id), "Extracted value '" ~ id.value ~ "'");
  }

  ExtractedField[] list(TenantId t) {
    return repos.extractedFields.findAll(t);
  }

  ExtractedField[] listOf(TenantId t, DocumentId document) {
    required(repos.documents.findById(t, document), "Document '" ~ document.value ~ "'");
    return valuesOf(t, document);
  }

  ExtractedField correct(TenantId t, ExtractedFieldId id, string value, UserId actor) {
    auto f = get(t, id);
    auto doc = required(repos.documents.findById(t, f.documentId), "Document '" ~ f.documentId.value ~ "'");
    if (!doc.isReviewable)
      throw DaiException.ruleViolation("Values can only be corrected while the document is done (document '"
          ~ doc.fileName ~ "' is " ~ cast(string) doc.status ~ ")");
    f.correct(value, actor.value);
    stampUpdated(f, actor, now);
    batch(() {
      repos.extractedFields.save(f);
      refreshSummary(t, doc, valuesOf(t, doc.id));
      stampUpdated(doc, actor, now);
      repos.documents.save(doc);
    });
    emit("field.corrected", t, id.value, Json(["documentId": Json(doc.id.value), "field": Json(f.name)]));
    return f;
  }
}
