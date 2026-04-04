/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.templates;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.template_;

interface TemplateRepository {
  Template findById(TemplateId id, ClientId clientId);
  Template[] findByClient(ClientId clientId);
  Template[] findBySchema(SchemaId schemaId, ClientId clientId);
  Template[] findByDocumentType(DocumentTypeId typeId, ClientId clientId);
  Template[] findByStatus(TemplateStatus status, ClientId clientId);
  void save(Template t);
  void update(Template t);
  void remove(TemplateId id, ClientId clientId);
  long countByClient(ClientId clientId);
}
