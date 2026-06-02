/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.section;


// import uim.platform.portal.application.usecases.manage.sections;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.section;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class SectionController : ManageController {
  private ManageSectionsUseCase useCase;

  this(ManageSectionsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/sections", &handleCreate);
    router.get("/api/v1/sections", &handleList);
    router.get("/api/v1/sections/*", &handleGet);
    router.put("/api/v1/sections/*", &handleUpdate);
    router.delete_("/api/v1/sections/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto createReq = CreateSectionRequest(data.getString("pageId"),
        req.headers.get("X-Tenant-Id", ""), data.getString("title"), jsonInt(j,
          "sortOrder"), data.getBoolean("visible", true), data.getInteger("columns", 3),);

      auto result = useCase.createSection(createReq);
      if (result.isSuccess()) {
        auto response = Json.emptyObject;
        response["id"] = Json(result.sectionId);
        res.writeJsonBody(response, 201);
      } else {
        writeApiError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto pageId = req.headers.get("X-Page-Id", "");
      auto sections = useCase.listSections(pageId);
      auto response = Json.emptyObject;
      response["totalResults"] = Json(sections.length);
      response["resources"] = toJsonArray(sections);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto sectionId = precheck.id;
      auto section = useCase.getSection(sectionId);
      if (section == PortalSection.init) {
        writeApiError(res, 404, "PortalSection not found");
        return;
      }
      res.writeJsonBody(toJsonValue(section), 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto sectionId = precheck.id;
      auto data = precheck.data;
      auto updateReq = UpdateSectionRequest(sectionId, data.getString("title"),
        data.getInteger("sortOrder"), data.getBoolean("visible", true), data.getInteger("columns", 3),);

      auto error = useCase.updateSection(updateReq);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto sectionId = precheck.id;
      auto data = precheck.data;
      auto pageId = data.getString("pageId");
      auto error = useCase.deleteSection(sectionId, pageId);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }
}
