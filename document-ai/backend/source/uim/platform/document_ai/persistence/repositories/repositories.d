/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.document_ai.persistence.repositories.repositories;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class ClientRepository : DocumentRepository!(Client, ClientId), IClientRepository {
  this(IDocumentStore store) {
    super(store, Collections.clients);
  }
}

class DocumentTypeRepository : DocumentRepository!(DocumentType, DocumentTypeId), IDocumentTypeRepository {
  this(IDocumentStore store) {
    super(store, Collections.documentTypes);
  }
}

class SchemaRepository : DocumentRepository!(Schema, SchemaId), ISchemaRepository {
  this(IDocumentStore store) {
    super(store, Collections.schemas);
  }
}

class SchemaFieldRepository : DocumentRepository!(SchemaField, SchemaFieldId), ISchemaFieldRepository {
  this(IDocumentStore store) {
    super(store, Collections.schemaFields);
  }
}

class TemplateRepository : DocumentRepository!(DocumentTemplate, TemplateId), ITemplateRepository {
  this(IDocumentStore store) {
    super(store, Collections.templates);
  }
}

class DocumentFileRepository : DocumentRepository!(AiDocument, DocumentId), IDocumentRepository {
  this(IDocumentStore store) {
    super(store, Collections.documents);
  }
}

class ExtractedFieldRepository : DocumentRepository!(ExtractedField, ExtractedFieldId), IExtractedFieldRepository {
  this(IDocumentStore store) {
    super(store, Collections.extractedFields);
  }
}

class EnrichmentDataRepository : DocumentRepository!(EnrichmentData, EnrichmentDataId), IEnrichmentDataRepository {
  this(IDocumentStore store) {
    super(store, Collections.enrichmentData);
  }
}

class TrainingJobRepository : DocumentRepository!(TrainingJob, TrainingJobId), ITrainingJobRepository {
  this(IDocumentStore store) {
    super(store, Collections.trainingJobs);
  }
}

class UserAccountRepository : DocumentRepository!(UserAccount, UserAccountId), IUserAccountRepository {
  this(IDocumentStore store) {
    super(store, Collections.users);
  }
}

/// All repositories over one document store.
DaiRepositories createRepositories(IDocumentStore store) {
  DaiRepositories r;
  r.clients = new ClientRepository(store);
  r.documentTypes = new DocumentTypeRepository(store);
  r.schemas = new SchemaRepository(store);
  r.schemaFields = new SchemaFieldRepository(store);
  r.templates = new TemplateRepository(store);
  r.documents = new DocumentFileRepository(store);
  r.extractedFields = new ExtractedFieldRepository(store);
  r.enrichmentData = new EnrichmentDataRepository(store);
  r.trainingJobs = new TrainingJobRepository(store);
  r.users = new UserAccountRepository(store);
  return r;
}
