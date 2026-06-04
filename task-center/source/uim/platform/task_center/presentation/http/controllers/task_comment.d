/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_comment;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskCommentController : ManageHttpController {
    private ManageTaskCommentsUseCase usecase;

    this(ManageTaskCommentsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/task-center/comments", &handleList);
        router.get("/api/v1/task-center/comments/*", &handleGet);
        router.post("/api/v1/task-center/comments", &handleCreate);
        router.put("/api/v1/task-center/comments/*", &handleUpdate);
        router.delete_("/api/v1/task-center/comments/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            CreateTaskCommentRequest r;
            r.tenantId = precheck.tenantId;
            r.taskCommentId = TaskCommentId(precheck.id);
            r.taskId = TaskId(data.getString("taskId"));
            r.author = data.getString("author");
            r.content = data.getString("content");

            auto result = usecase.create(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Comment created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto params = req.queryParams();
            auto taskId = TaskId(params.get("taskId", ""));

            TaskComment[] comments = !taskId.isEmpty
                ? usecase.listCommentsByTask(tenantId, taskId) : [];    

            auto jarr = comments.map!(c => c.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", comments.length)
                .set("resources", jarr)
                .set("message", "Comment list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = TaskCommentId(precheck.id);
            auto c = usecase.getById(tenantId, id);
            if (c.isNull) {
                writeError(res, 404, "Comment not found");
                return;
            }
            res.writeJsonBody(commentToJson(c), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = TaskCommentId(precheck.id);
            auto data = precheck.data;
            UpdateTaskCommentRequest r;
            r.tenantId = precheck.tenantId;
            r.taskCommentId = id;
            r.content = data.getString("content");

            auto result = usecase.update(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Comment updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = TaskCommentId(precheck.id);
            auto result = usecase.deleteTaskComment(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Comment deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

}
