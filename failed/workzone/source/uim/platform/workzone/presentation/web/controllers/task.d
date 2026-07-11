/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.controllers.task;

import uim.platform.workzone;
import uim.platform.workzone.presentation.web.models.task;
import uim.platform.workzone.presentation.web.views.task;
import uim.platform.workzone.presentation.web.views.error;

mixin(ShowModule!());

@safe:
/// Web MVC controller — renders HTML for the My Tasks inbox.
class TaskWebController : ManageHttpController {
    private ManageTasksUseCase useCase;

    this(ManageTasksUseCase useCase) {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/ui/tasks", &handleList);
    }

    private void handleList(scope HTTPServerRequest req,
                            scope HTTPServerResponse res) {
        immutable tenantId  = tenantId;
        immutable assigneeId = req.query.get("assignee", "");
        try {
            WZTask[] tasks;
            if (assigneeId.length > 0)
                tasks = useCase.listByAssignee(tenantId, UserId(assigneeId));
            else
                tasks = useCase.listTasks(tenantId);

            TaskListViewModel vm;
            vm.tenantId   = tenantId;
            vm.assigneeId = assigneeId;
            foreach (t; tasks) {
                auto tvm = TaskViewModel.from(t);
                vm.items ~= tvm;
                if (t.status == TaskStatus.open || t.status == TaskStatus.inProgress)
                    vm.openCount++;
                if (tvm.isOverdue)
                    vm.overdueCount++;
            }
            res.writeBody(renderTaskList(vm), "text/html; charset=utf-8");
        } catch (Exception e) {
            TaskListViewModel vm;
            vm.errorMessage = e.msg;
            res.statusCode = 500;
            res.writeBody(renderTaskList(vm), "text/html; charset=utf-8");
        }
    }
}
