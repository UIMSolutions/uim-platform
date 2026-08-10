/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.usecases.document_types;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
interface IManageDocumentTypesUseCase {
  
  CommandResult createDocumentType(CreateDocumentTypeRequest r);
  CommandResult updateDocumentType(UpdateDocumentTypeRequest r);
  DocumentType getDocumentType(DocumentTypeId id, ClientId clientId);
  DocumentType[] listDocumentTypes(ClientId clientId);
  DocumentType[] listDocumentTypes(DocumentCategory category, ClientId clientId);
  CommandResult deleteDocumentType(ClientId clientId, DocumentTypeId id);
  size_t count(ClientId clientId);

}
