/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.infrastructure.persistence.memory.documents;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class MemoryDocumentRepository : DocumentRepository {
    private Document[] store;

    Document[] findAll() { return store; }

    Document* findById(DocumentId id) {
        foreach (ref d; store)
            if (d.id == id) return &d;
        return null;
    }

    Document[] findByTenant(TenantId tenantId) {
        Document[] result;
        foreach (ref d; store)
            if (d.tenantId == tenantId) result ~= d;
        return result;
    }

    Document[] findByEquipment(string equipmentId) {
        Document[] result;
        foreach (ref d; store)
            if (d.equipmentId == equipmentId) result ~= d;
        return result;
    }

    Document[] findByModel(string modelId) {
        Document[] result;
        foreach (ref d; store)
            if (d.modelId == modelId) result ~= d;
        return result;
    }

    Document[] findByType(DocumentType documentType) {
        Document[] result;
        foreach (ref d; store)
            if (d.documentType == documentType) result ~= d;
        return result;
    }

    void save(Document document) { store ~= document; }

    void update(Document document) {
        foreach (ref d; store)
            if (d.id == document.id) { d = document; return; }
    }

    void remove(DocumentId id) {
        import std.algorithm : remove;
        store = store.remove!(d => d.id == id);
    }
}
