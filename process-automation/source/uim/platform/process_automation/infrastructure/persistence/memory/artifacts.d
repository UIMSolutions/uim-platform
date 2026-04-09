/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.artifacts;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryArtifactRepository : ArtifactRepository {
    private Artifact[] store;

    Artifact findById(ArtifactId id) {
        foreach (ref a; store) {
            if (a.id == id)
                return a;
        }
        return Artifact.init;
    }

    Artifact[] findAll() {
        return store.dup;
    }

    Artifact[] findByType(ArtifactType type) {
        return store.filter!(a => a.type == type).array;
    }

    Artifact[] findByCategory(string category) {
        return store.filter!(a => a.category == category).array;
    }

    void save(Artifact a) {
        store ~= a;
    }

    void update(Artifact a) {
        foreach (ref existing; store) {
            if (existing.id == a.id) {
                existing = a;
                return;
            }
        }
    }

    void remove(ArtifactId id) {
        store = store.filter!(a => a.id != id).array;
    }

    size_t countAll() {
        return cast(long) store.length;
    }
}
