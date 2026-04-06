/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.infrastructure.container;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

struct Container {
    ManageProductsUseCase manageProductsUseCase;
    ManageBomsUseCase manageBomsUseCase;
    ManageChangeRequestsUseCase manageChangeRequestsUseCase;
    ManageDocumentsUseCase manageDocumentsUseCase;
    ManageSpecificationsUseCase manageSpecificationsUseCase;
    ManageRecipesUseCase manageRecipesUseCase;
    ManageCollaborationsUseCase manageCollaborationsUseCase;
    ManageProductStructuresUseCase manageProductStructuresUseCase;

    ProductController productController;
    BomController bomController;
    ChangeRequestController changeRequestController;
    DocumentController documentController;
    SpecificationController specificationController;
    RecipeController recipeController;
    CollaborationController collaborationController;
    ProductStructureController productStructureController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container c;

    // Repositories
    auto productRepo = new MemoryProductRepository();
    auto bomRepo = new MemoryBomRepository();
    auto changeRequestRepo = new MemoryChangeRequestRepository();
    auto documentRepo = new MemoryDocumentRepository();
    auto specificationRepo = new MemorySpecificationRepository();
    auto recipeRepo = new MemoryRecipeRepository();
    auto collaborationRepo = new MemoryCollaborationRepository();
    auto productStructureRepo = new MemoryProductStructureRepository();

    // Use Cases
    c.manageProductsUseCase = new ManageProductsUseCase(productRepo);
    c.manageBomsUseCase = new ManageBomsUseCase(bomRepo);
    c.manageChangeRequestsUseCase = new ManageChangeRequestsUseCase(changeRequestRepo);
    c.manageDocumentsUseCase = new ManageDocumentsUseCase(documentRepo);
    c.manageSpecificationsUseCase = new ManageSpecificationsUseCase(specificationRepo);
    c.manageRecipesUseCase = new ManageRecipesUseCase(recipeRepo);
    c.manageCollaborationsUseCase = new ManageCollaborationsUseCase(collaborationRepo);
    c.manageProductStructuresUseCase = new ManageProductStructuresUseCase(productStructureRepo);

    // Controllers
    c.productController = new ProductController(c.manageProductsUseCase);
    c.bomController = new BomController(c.manageBomsUseCase);
    c.changeRequestController = new ChangeRequestController(c.manageChangeRequestsUseCase);
    c.documentController = new DocumentController(c.manageDocumentsUseCase);
    c.specificationController = new SpecificationController(c.manageSpecificationsUseCase);
    c.recipeController = new RecipeController(c.manageRecipesUseCase);
    c.collaborationController = new CollaborationController(c.manageCollaborationsUseCase);
    c.productStructureController = new ProductStructureController(c.manageProductStructuresUseCase);
    c.healthController = new HealthController();

    return c;
}
