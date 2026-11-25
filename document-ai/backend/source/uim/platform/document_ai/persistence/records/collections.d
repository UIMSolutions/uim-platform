/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document collections. A record is a flat JSON object: the audit fields
/// (id, tenantId, createdAt/By, updatedAt/By — std time) plus the entity
/// attributes under their API names (references such as "documentId" can
/// therefore be filtered without mapping).
module uim.platform.document_ai.persistence.records.collections;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

enum Collections : string {
  clients = "dai.clients",
  documentTypes = "dai.documentTypes",
  schemas = "dai.schemas",
  schemaFields = "dai.schemaFields",
  templates = "dai.templates",
  documents = "dai.documents",
  extractedFields = "dai.extractedFields",
  enrichmentData = "dai.enrichmentData",
  trainingJobs = "dai.trainingJobs",
  users = "dai.users"
}
