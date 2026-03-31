module application.usecases.detect_duplicates;

import domain.types;
import domain.entities.match_group;
import domain.ports.match_group_repository;
import domain.services.duplicate_detector;
import application.dto;

import std.datetime.systime : Clock;

class DetectDuplicatesUseCase
{
    private MatchGroupRepository repo;
    private DuplicateDetector detector;

    this(MatchGroupRepository repo, DuplicateDetector detector)
    {
        this.repo = repo;
        this.detector = detector;
    }

    /// Run duplicate detection on a set of records.
    MatchGroup[] detect(DetectDuplicatesRequest req)
    {
        // Convert DTO records to domain RecordEntry
        RecordEntry[] entries;
        foreach (ref r; req.records)
        {
            RecordEntry e;
            e.recordId = r.recordId;
            e.fields = r.fieldValues;
            entries ~= e;
        }

        auto groups = detector.detect(
            req.tenantId, req.datasetId,
            req.matchFields, req.strategy,
            req.threshold, entries);

        // Persist all match groups
        foreach (ref g; groups)
            repo.save(g);

        return groups;
    }

    /// Resolve a duplicate group by selecting a survivor record.
    CommandResult resolve(ResolveDuplicateRequest req)
    {
        auto group = repo.findById(req.groupId, req.tenantId);
        if (group is null)
            return CommandResult("", "Match group not found");

        auto g = *group;
        g.survivorRecordId = req.survivorRecordId;
        g.resolved = true;
        g.resolvedAt = Clock.currStdTime();

        // Mark the chosen survivor
        foreach (ref c; g.candidates)
            c.isSurvivor = (c.recordId == req.survivorRecordId);

        repo.update(g);
        return CommandResult(g.id, "");
    }

    /// Get all match groups for a dataset.
    MatchGroup[] getByDataset(TenantId tenantId, DatasetId datasetId)
    {
        return repo.findByDataset(tenantId, datasetId);
    }

    /// Get unresolved match groups.
    MatchGroup[] getUnresolved(TenantId tenantId)
    {
        return repo.findUnresolved(tenantId);
    }

    /// Get a single match group by ID.
    MatchGroup* getById(MatchGroupId id, TenantId tenantId)
    {
        return repo.findById(id, tenantId);
    }
}
