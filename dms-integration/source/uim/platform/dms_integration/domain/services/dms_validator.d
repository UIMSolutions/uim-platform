/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.services.dms_validator;

import uim.platform.dms_integration;
mixin(ShowModule!());

@safe:

struct DmsValidator {

    static bool isValidRepository(const ref Repository_ repo) {
        return repo.name.length > 0;
    }

    static bool isValidDocument(const ref Document doc) {
        return doc.name.length > 0 && !doc.repositoryId.isEmpty;
    }

    static bool isValidFolder(const ref Folder folder) {
        return folder.name.length > 0 && !folder.repositoryId.isEmpty;
    }

    static bool isValidDocumentVersion(const ref DocumentVersion ver) {
        return !ver.documentId.isEmpty && ver.versionLabel.length > 0;
    }

    static bool isValidPermission(const ref Permission perm) {
        return perm.principalId.length > 0 &&
               (!perm.documentId.isEmpty || !perm.folderId.isEmpty);
    }
}
