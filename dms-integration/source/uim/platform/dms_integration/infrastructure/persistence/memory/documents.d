/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.infrastructure.persistence.memory.documents;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class MemoryDocumentRepository : TenantRepository!(Document, DocumentId), DocumentRepository {

    size_t countByRepository(TenantId tenantId, RepositoryId repositoryId) {
        return findByRepository(tenantId, repositoryId).length;
    }
    Document[] findByRepository(TenantId tenantId, RepositoryId repositoryId) {
        return findByTenant(tenantId).filter!(e => e.repositoryId == repositoryId).array;
    }
    void removeByRepository(TenantId tenantId, RepositoryId repositoryId) {
        findByRepository(tenantId, repositoryId).each!(e => remove(e));
    }

    size_t countByFolder(TenantId tenantId, FolderId folderId) {
        return findByFolder(tenantId, folderId).length;
    }
    Document[] findByFolder(TenantId tenantId, FolderId folderId) {
        return findByTenant(tenantId).filter!(e => e.folderId == folderId).array;
    }
    void removeByFolder(TenantId tenantId, FolderId folderId) {
        findByFolder(tenantId, folderId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, DocumentStatus status) {
        return findByStatus(tenantId, status).length;
    }
    Document[] findByStatus(TenantId tenantId, DocumentStatus status) {
        return findByTenant(tenantId).filter!(e => e.documentStatus == status).array;
    }

    Document[] findCheckedOut(TenantId tenantId) {
        return findByTenant(tenantId).filter!(e => e.checkoutStatus == CheckoutStatus.checkedOut).array;
    }
    Document[] findCheckedOutBy(TenantId tenantId, UserId userId) {
        return findByTenant(tenantId).filter!(e => e.checkoutStatus == CheckoutStatus.checkedOut && e.checkedOutBy == userId).array;
    }

    Document[] searchByName(TenantId tenantId, string searchTerm) {
        import std.string : toLower, indexOf;
        auto term = searchTerm.toLower;
        return findByTenant(tenantId).filter!(e => e.name.toLower.indexOf(term) >= 0).array;
    }
}
