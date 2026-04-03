module uim.platform.workzone.infrastructure.persistence.memory.task_repo;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.task;
import uim.platform.workzone.domain.ports.task_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryTaskRepository : TaskRepository
{
    private Task[TaskId] store;

    Task[] findByAssignee(UserId assigneeId, TenantId tenantId)
    {
        return store.byValue().filter!(t => t.tenantId == tenantId && t.assigneeId == assigneeId).array;
    }

    Task* findById(TaskId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    Task[] findByStatus(TaskStatus status, UserId assigneeId, TenantId tenantId)
    {
        return store.byValue().filter!(t =>
            t.tenantId == tenantId && t.assigneeId == assigneeId && t.status == status
        ).array;
    }

    Task[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(t => t.tenantId == tenantId).array;
    }

    void save(Task task) { store[task.id] = task; }
    void update(Task task) { store[task.id] = task; }
    void remove(TaskId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}
