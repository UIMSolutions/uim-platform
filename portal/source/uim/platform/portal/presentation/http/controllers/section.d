module uim.platform.portal.presentation.http.controllers.section;

// import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import uim.platform.portal.application.usecases.manage_sections;
import uim.platform.portal.application.dto;
import uim.platform.portal.domain.entities.section;
import uim.platform.portal.domain.types;
import uim.platform.identity_authentication.presentation.http.json_utils;

class SectionController
{
    private ManageSectionsUseCase useCase;

    this(ManageSectionsUseCase useCase)
    {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/sections", &handleCreate);
        router.get("/api/v1/sections", &handleList);
        router.get("/api/v1/sections/*", &handleGet);
        router.put("/api/v1/sections/*", &handleUpdate);
        router.delete_("/api/v1/sections/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto createReq = CreateSectionRequest(
                j.getString("pageId"),
                req.headers.get("X-Tenant-Id", ""),
                j.getString("title"),
                jsonInt(j, "sortOrder"),
                j.getBoolean("visible", true),
                jsonInt(j, "columns", 3),
            );

            auto result = useCase.createSection(createReq);
            if (result.isSuccess())
            {
                auto response = Json.emptyObject;
                response["id"] = Json(result.sectionId);
                res.writeJsonBody(response, 201);
            }
            else
            {
                writeApiError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto pageId = req.headers.get("X-Page-Id", "");
            auto sections = useCase.listSections(pageId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) sections.length);
            response["resources"] = toJsonArray(sections);
            res.writeJsonBody(response, 200);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto sectionId = extractIdFromPath(req.requestURI);
            auto section = useCase.getSection(sectionId);
            if (section == Section.init)
            {
                writeApiError(res, 404, "Section not found");
                return;
            }
            res.writeJsonBody(toJsonValue(section), 200);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto sectionId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto updateReq = UpdateSectionRequest(
                sectionId,
                j.getString("title"),
                jsonInt(j, "sortOrder"),
                j.getBoolean("visible", true),
                jsonInt(j, "columns", 3),
            );

            auto error = useCase.updateSection(updateReq);
            if (error.length > 0)
                writeApiError(res, 404, error);
            else
                res.writeJsonBody(Json.emptyObject, 200);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto sectionId = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto pageId = j.getString("pageId");
            auto error = useCase.deleteSection(sectionId, pageId);
            if (error.length > 0)
                writeApiError(res, 404, error);
            else
                res.writeJsonBody(Json.emptyObject, 204);
        }
        catch (Exception e)
        {
            writeApiError(res, 500, "Internal server error");
        }
    }
}
