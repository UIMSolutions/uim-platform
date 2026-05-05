/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.extensions;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryExtensionRepository : TenantRepository!(Extension, ExtensionId), ExtensionRepository {

    size_t countByScope(ExtensionScope scope_) {
        return findByScope(scope_).length;
    }

    Extension[] findByScope(ExtensionScope scope_) {
        return findAll().filter!(e => e.scope_ == scope_).array;
    }

    void removeByScope(ExtensionScope scope_) {
        findByScope(scope_).each!(e => remove(e));
    }

    size_t countByStatus(ExtensionStatus status) {
        return findByStatus(status).length;
    }

    Extension[] findByStatus(ExtensionStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void removeByStatus(ExtensionStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}
