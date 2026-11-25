/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.document_ai.ports.repositories.repositories;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

interface IClientRepository : IDaiRepository!(Client, ClientId) {
}

interface IDocumentTypeRepository : IDaiRepository!(DocumentType, DocumentTypeId) {
}

interface ISchemaRepository : IDaiRepository!(Schema, SchemaId) {
}

interface ISchemaFieldRepository : IDaiRepository!(SchemaField, SchemaFieldId) {
}

interface ITemplateRepository : IDaiRepository!(DocumentTemplate, TemplateId) {
}

interface IDocumentRepository : IDaiRepository!(AiDocument, DocumentId) {
}

interface IExtractedFieldRepository : IDaiRepository!(ExtractedField, ExtractedFieldId) {
}

interface IEnrichmentDataRepository : IDaiRepository!(EnrichmentData, EnrichmentDataId) {
}

interface ITrainingJobRepository : IDaiRepository!(TrainingJob, TrainingJobId) {
}

interface IUserAccountRepository : IDaiRepository!(UserAccount, UserAccountId) {
}

/// All repositories (passed to the interactors as one bundle).
struct DaiRepositories {
  IClientRepository clients;
  IDocumentTypeRepository documentTypes;
  ISchemaRepository schemas;
  ISchemaFieldRepository schemaFields;
  ITemplateRepository templates;
  IDocumentRepository documents;
  IExtractedFieldRepository extractedFields;
  IEnrichmentDataRepository enrichmentData;
  ITrainingJobRepository trainingJobs;
  IUserAccountRepository users;
}
