/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.container;

// import uim.platform.document_ai.infrastructure.config;

// // Repositories
// import uim.platform.document_ai.infrastructure.persistence.memory.document;
// import uim.platform.document_ai.infrastructure.persistence.memory.extraction_result;
// import uim.platform.document_ai.infrastructure.persistence.memory.schema;
// import uim.platform.document_ai.infrastructure.persistence.memory.template;
// import uim.platform.document_ai.infrastructure.persistence.memory.document_type;
// import uim.platform.document_ai.infrastructure.persistence.memory.enrichment_data;
// import uim.platform.document_ai.infrastructure.persistence.memory.training_job;
// import uim.platform.document_ai.infrastructure.persistence.memory.client;

// // Use Cases
// import uim.platform.document_ai.application.usecases.process_documents;
// import uim.platform.document_ai.application.usecases.manage.schemas;
// import uim.platform.document_ai.application.usecases.manage.templates;
// import uim.platform.document_ai.application.usecases.manage.document_types;
// import uim.platform.document_ai.application.usecases.manage.enrichment_data;
// import uim.platform.document_ai.application.usecases.manage.training_jobs;
// import uim.platform.document_ai.application.usecases.manage.clients;
// import uim.platform.document_ai.application.usecases.get_capabilities;

// // Controllers
// import uim.platform.document_ai.presentation.http.controllers.document;
// import uim.platform.document_ai.presentation.http.controllers.schema;
// import uim.platform.document_ai.presentation.http.controllers.template_;
// import uim.platform.document_ai.presentation.http.controllers.document_type;
// import uim.platform.document_ai.presentation.http.controllers.enrichment_data;
// import uim.platform.document_ai.presentation.http.controllers.training_job;
// import uim.platform.document_ai.presentation.http.controllers.client;
// import uim.platform.document_ai.presentation.http.controllers.capabilities;
// import uim.platform.document_ai.presentation.http.controllers.health;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct Container {
  // Repositories (driven adapters)
  MemoryDocumentRepository documentRepo;
  MemoryExtractionResultRepository extractionResultRepo;
  MemorySchemaRepository schemaRepo;
  MemoryTemplateRepository templateRepo;
  MemoryDocumentTypeRepository documentTypeRepo;
  MemoryEnrichmentDataRepository enrichmentDataRepo;
  MemoryTrainingJobRepository trainingJobRepo;
  MemoryClientRepository clientRepo;

  // Use cases (application layer)
  ProcessDocumentsUseCase processDocuments;
  ManageSchemasUseCase manageSchemas;
  ManageTemplatesUseCase manageTemplates;
  ManageDocumentTypesUseCase manageDocumentTypes;
  ManageEnrichmentDataUseCase manageEnrichmentData;
  ManageTrainingJobsUseCase manageTrainingJobs;
  ManageClientsUseCase manageClients;
  GetCapabilitiesUseCase getCapabilities;

  // Controllers (driving adapters)
  DocumentController documentController;
  SchemaController schemaController;
  TemplateController templateController;
  DocumentTypeController documentTypeController;
  EnrichmentDataController enrichmentDataController;
  TrainingJobController trainingJobController;
  ClientController clientController;
  CapabilitiesController capabilitiesController;
  HealthController healthController;
}

Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.documentRepo = new MemoryDocumentRepository();
  c.extractionResultRepo = new MemoryExtractionResultRepository();
  c.schemaRepo = new MemorySchemaRepository();
  c.templateRepo = new MemoryTemplateRepository();
  c.documentTypeRepo = new MemoryDocumentTypeRepository();
  c.enrichmentDataRepo = new MemoryEnrichmentDataRepository();
  c.trainingJobRepo = new MemoryTrainingJobRepository();
  c.clientRepo = new MemoryClientRepository();

  // Application use cases
  c.processDocuments = new ProcessDocumentsUseCase(c.documentRepo, c.extractionResultRepo);
  c.manageSchemas = new ManageSchemasUseCase(c.schemaRepo);
  c.manageTemplates = new ManageTemplatesUseCase(c.templateRepo);
  c.manageDocumentTypes = new ManageDocumentTypesUseCase(c.documentTypeRepo);
  c.manageEnrichmentData = new ManageEnrichmentDataUseCase(c.enrichmentDataRepo);
  c.manageTrainingJobs = new ManageTrainingJobsUseCase(c.trainingJobRepo, c.documentRepo);
  c.manageClients = new ManageClientsUseCase(c.clientRepo);
  c.getCapabilities = new GetCapabilitiesUseCase();

  // Presentation controllers
  c.documentController = new DocumentController(c.processDocuments);
  c.schemaController = new SchemaController(c.manageSchemas);
  c.templateController = new TemplateController(c.manageTemplates);
  c.documentTypeController = new DocumentTypeController(c.manageDocumentTypes);
  c.enrichmentDataController = new EnrichmentDataController(c.manageEnrichmentData);
  c.trainingJobController = new TrainingJobController(c.manageTrainingJobs);
  c.clientController = new ClientController(c.manageClients);
  c.capabilitiesController = new CapabilitiesController(c.getCapabilities);
  c.healthController = new HealthController("document-ai");

  return c;
}
