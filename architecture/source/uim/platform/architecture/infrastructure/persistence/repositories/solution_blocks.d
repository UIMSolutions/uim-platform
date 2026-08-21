/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.architecture.infrastructure.persistence.repositories.solution_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class SolutionBlockRepository : TenantRepository!(SolutionBlock, SolutionBlockId), ISolutionBlockRepository {
     
    size_t countByStatus(TenantId tenantId, LifecycleStatus status) {
        return findByStatus(tenantId, status).length;
    }

    SolutionBlock[] filterByStatus(SolutionBlock[] blocks, LifecycleStatus status) {
        return blocks.filter!(block => block.status == status).array;
    }

    SolutionBlock[] findByStatus(TenantId tenantId, LifecycleStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, LifecycleStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
    
}
///
unittest {

    void testSolutionBlockRepository() {
        auto repo = new SolutionBlockRepository();
        auto tenantId = TenantId("tenant1");
        auto block1 = SolutionBlock(tenantId, SolutionBlockId("block1"));
        block1.title = "Block 1";
        block1.description = "Description 1";
        block1.status = LifecycleStatus.active;
        repo.save(block1);

        auto block2 = SolutionBlock(tenantId, SolutionBlockId("block2"));
        block2.title = "Block 2";
        block2.description = "Description 2";
        block2.status = LifecycleStatus.deprecated_;
        repo.save(block2);

        auto block3 = SolutionBlock(tenantId, SolutionBlockId("block3"));
        block3.title = "Block 3";
        block3.description = "Description 3";
        block3.status = LifecycleStatus.active;
        repo.save(block3);

        assert(repo.countByTenant(tenantId) == 3);
        assert(repo.countByStatus(tenantId, LifecycleStatus.active) == 2);
        assert(repo.countByStatus(tenantId, LifecycleStatus.deprecated_) == 1);

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

    testSolutionBlockRepository();
}
