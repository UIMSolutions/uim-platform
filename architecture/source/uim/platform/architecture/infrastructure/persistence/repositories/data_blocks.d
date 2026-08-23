/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.architecture.infrastructure.persistence.repositories.data_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class DataBlockRepository : TenantRepository!(DataBlock, DataBlockId), IDataBlockRepository {

    size_t countByStatus(TenantId tenantId, LifecycleStatus status) {
        return findByStatus(tenantId, status).length;
    }

    DataBlock[] filterByStatus(DataBlock[] blocks, LifecycleStatus status) {
        return blocks.filter!(block => block.status == status).array;
    }

    DataBlock[] findByStatus(TenantId tenantId, LifecycleStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    size_t countByDomain(TenantId tenantId, ArchiMateDomain domain) {
        return findByDomain(tenantId, domain).length;
    }

    DataBlock[] filterByDomain(DataBlock[] blocks, ArchiMateDomain domain) {
        return blocks.filter!(block => block.archimateDomain == domain).array;
    }

    DataBlock[] findByDomain(TenantId tenantId, ArchiMateDomain domain) {
        return filterByDomain(findByTenant(tenantId), domain);
    }

    size_t countByAspect(TenantId tenantId, ArchiMateAspect aspect) {
        return findByAspect(tenantId, aspect).length;
    }

    DataBlock[] filterByAspect(DataBlock[] blocks, ArchiMateAspect aspect) {
        return blocks.filter!(block => block.archimateAspect == aspect).array;
    }

    DataBlock[] findByAspect(TenantId tenantId, ArchiMateAspect aspect) {
        return filterByAspect(findByTenant(tenantId), aspect);
    }

    size_t countByLeanIXObjectType(TenantId tenantId, LeanIXDataObjectType objectType) {
        return findByLeanIXObjectType(tenantId, objectType).length;
    }

    DataBlock[] filterByLeanIXObjectType(DataBlock[] blocks, LeanIXDataObjectType objectType) {
        return blocks.filter!(block => block.leanixObjectType == objectType).array;
    }

    DataBlock[] findByLeanIXObjectType(TenantId tenantId, LeanIXDataObjectType objectType) {
        return filterByLeanIXObjectType(findByTenant(tenantId), objectType);
    }

    void removeByStatus(TenantId tenantId, LifecycleStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    void removeByDomain(TenantId tenantId, ArchiMateDomain domain) {
        findByDomain(tenantId, domain).each!(e => remove(e));
    }

    void removeByAspect(TenantId tenantId, ArchiMateAspect aspect) {
        findByAspect(tenantId, aspect).each!(e => remove(e));
    }

    void removeByLeanIXObjectType(TenantId tenantId, LeanIXDataObjectType objectType) {
        findByLeanIXObjectType(tenantId, objectType).each!(e => remove(e));
    }

}
///
unittest {

    void testDataBlockRepository() {
        auto repo = new DataBlockRepository();
        auto tenantId = TenantId("tenant1");
        auto block1 = DataBlock(tenantId, DataBlockId("block1"));
        block1.title = "Block 1";
        block1.description = "Description 1";
        block1.status = LifecycleStatus.active;
        block1.archimateDomain = ArchiMateDomain.application;
        block1.archimateAspect = ArchiMateAspect.passiveStructure;
        block1.leanixObjectType = LeanIXDataObjectType.masterData;
        repo.save(block1);

        auto block2 = DataBlock(tenantId, DataBlockId("block2"));
        block2.title = "Block 2";
        block2.description = "Description 2";
        block2.status = LifecycleStatus.deprecated_;
        block2.archimateDomain = ArchiMateDomain.technology;
        block2.archimateAspect = ArchiMateAspect.activeStructure;
        block2.leanixObjectType = LeanIXDataObjectType.apiPayload;
        repo.save(block2);

        auto block3 = DataBlock(tenantId, DataBlockId("block3"));
        block3.title = "Block 3";
        block3.description = "Description 3";
        block3.status = LifecycleStatus.active;
        block3.archimateDomain = ArchiMateDomain.application;
        block3.archimateAspect = ArchiMateAspect.passiveStructure;
        block3.leanixObjectType = LeanIXDataObjectType.masterData;
        repo.save(block3);

        assert(repo.countByTenant(tenantId) == 3);
        assert(repo.countByStatus(tenantId, LifecycleStatus.active) == 2);
        assert(repo.countByStatus(tenantId, LifecycleStatus.deprecated_) == 1);
        assert(repo.countByDomain(tenantId, ArchiMateDomain.application) == 2);
        assert(repo.countByDomain(tenantId, ArchiMateDomain.technology) == 1);
        assert(repo.countByAspect(tenantId, ArchiMateAspect.passiveStructure) == 2);
        assert(repo.countByAspect(tenantId, ArchiMateAspect.activeStructure) == 1);
        assert(repo.countByLeanIXObjectType(tenantId, LeanIXDataObjectType.masterData) == 2);
        assert(repo.countByLeanIXObjectType(tenantId, LeanIXDataObjectType.apiPayload) == 1);

        auto activeBlocks = repo.findByStatus(tenantId, LifecycleStatus.active);
        assert(activeBlocks.length == 2);
        assert(activeBlocks[0].id == block1.id || activeBlocks[0].id == block3.id);
        assert(activeBlocks[1].id == block1.id || activeBlocks[1].id == block3.id);

        repo.removeByStatus(tenantId, LifecycleStatus.deprecated_);
        assert(repo.countByStatus(tenantId, LifecycleStatus.deprecated_) == 0);
        assert(repo.countByStatus(tenantId, LifecycleStatus.active) == 2);
        assert(repo.countByTenant(tenantId) == 2);

        repo.removeByTenant(tenantId);
        assert(repo.countByTenant(tenantId) == 0);
    }

    testDataBlockRepository();
}
