module domain.ports.task_repository;

import domain.types;
import domain.entities.task;

interface TaskRepository
{
    Task[] findByAssignee(UserId assigneeId, TenantId tenantId);
    Task* findById(TaskId id, TenantId tenantId);
    Task[] findByStatus(TaskStatus status, UserId assigneeId, TenantId tenantId);
    Task[] findByTenant(TenantId tenantId);
    void save(Task task);
    void update(Task task);
    void remove(TaskId id, TenantId tenantId);
}
