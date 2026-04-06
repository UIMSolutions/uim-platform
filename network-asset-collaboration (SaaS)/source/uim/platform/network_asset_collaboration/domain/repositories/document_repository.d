/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.repositories.document_repository;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

interface DocumentRepository {
    Document[] findAll();
    Document* findById(DocumentId id);
    Document[] findByTenant(TenantId tenantId);
    Document[] findByEquipment(string equipmentId);
    Document[] findByModel(string modelId);
    Document[] findByType(DocumentType documentType);
    void save(Document document);
    void update(Document document);
    void remove(DocumentId id);
}
