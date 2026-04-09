/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.artifacts;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageArtifactsUseCase : UIMUseCase {
    private ArtifactRepository repo;

    this(ArtifactRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateArtifactRequest r) {
        if (r.id.isEmpty)
            return CommandResult(false, "", "Artifact ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Artifact name is required");

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Artifact already exists");

        Artifact a;
        a.id = r.id;
        a.name = r.name;
        a.description = r.description;
        a.status = ArtifactStatus.available;
        a.version_ = r.version_;
        a.author = r.author;
        a.category = r.category;
        a.tags = r.tags;
        a.contentUrl = r.contentUrl;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        a.publishedAt = now;
        a.updatedAt = now;

        repo.save(a);
        return CommandResult(true, a.id, "");
    }

    Artifact get_(ArtifactId id) {
        return repo.findById(id);
    }

    Artifact[] list() {
        return repo.findAll();
    }

    Artifact[] listByType(ArtifactType type) {
        return repo.findByType(type);
    }

    CommandResult update(UpdateArtifactRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Artifact not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.version_ = r.version_;
        existing.contentUrl = r.contentUrl;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(ArtifactId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Artifact not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
