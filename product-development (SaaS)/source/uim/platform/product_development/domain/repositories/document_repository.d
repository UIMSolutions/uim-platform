/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.repositories.document_repository;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

interface DocumentRepository {
    Document[] findAll();
    Document* findById(DocumentId id);
    Document[] findByTenant(TenantId tenantId);
    Document[] findByProduct(string productId);
    Document[] findByType(DocumentType documentType);
    Document[] findByStatus(DocumentStatus status);
    void save(Document doc);
    void update(Document doc);
    void remove(DocumentId id);
}
