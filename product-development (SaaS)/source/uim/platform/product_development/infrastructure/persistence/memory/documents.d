/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.infrastructure.persistence.memory.documents;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class MemoryDocumentRepository : DocumentRepository {
    private Document[] store;

    Document[] findAll() { return store; }

    Document* findById(DocumentId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    Document[] findByTenant(TenantId tenantId) {
        Document[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Document[] findByProduct(string productId) {
        Document[] result;
        foreach (ref e; store)
            if (e.productId == productId) result ~= e;
        return result;
    }

    Document[] findByType(DocumentType documentType) {
        Document[] result;
        foreach (ref e; store)
            if (e.documentType == documentType) result ~= e;
        return result;
    }

    Document[] findByStatus(DocumentStatus status) {
        Document[] result;
        foreach (ref e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    void save(Document doc) { store ~= doc; }

    void update(Document doc) {
        foreach (ref e; store)
            if (e.id == doc.id) { e = doc; return; }
    }

    void remove(DocumentId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
