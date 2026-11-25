/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (REST, OData,
/// CLI, GUI, workers) may call.
module uim.platform.document_ai.ports.driving;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct DaiPorts {
  IManageClients clients;
  IManageDocumentTypes documentTypes;
  IManageSchemas schemas;
  IManageSchemaFields schemaFields;
  IManageTemplates templates;
  IManageEnrichmentData enrichmentData;
  IProcessDocuments documents;
  IReviewFields fields;
  IManageTrainingJobs trainingJobs;
  IDaiStatisticsService statistics;
  IAuthenticate authentication;
  IManageUsers users;
}
