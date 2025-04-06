/****************************************************************************************************************
* Copyright: © 2017-2024 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.mixins.stringcontents;

import uim.views;
@safe:

/* * Adds string template functionality to any class by providing methods to
 * load and parse string templates.
 *
 * This mixin template requires the implementing class to provide a `config()`
 * method for reading/updating templates. An implementation of this method
 * is provided by `UIM\Core\InstanceConfigTrait`
 */
mixin template TStringContents() {
    /*
    // StringContents instance.
    protected DStringContents _templater = null;

    // #region set
    // Sets templates to use.
    void setTemplates(string[] newTemplates) {
        templater().add(newTemplates);
    }
    // #endregion set
    
    // Gets templates to use or a specific template.
    string[] getTemplates(string templateName = null) {
        return _templater().get(templateName);
    }
    
    // Formats a template string with mydata
    string formatTemplate(string templateName, Json[string] dataToInsert) {
        return _templater().format(templateName, mydata);
    }
    
    // Returns the templater instance.
    StringContents templater() {
        if (_templater.isNull) {
            /** @var class-string<\UIM\View\StringContents> myclass * /
            string myclass = configuration.getStringEntry("templateClass", StringContents.classname);
           _templater = new myclass();

            mytemplates = configurationData.get("templates");
            if (mytemplates) {
                if (isString(mytemplates)) {
                   _templater.add(_defaultconfiguration.getEntry("templates");
                   _templater.load(mytemplates);
                } else {
                   _templater.add(mytemplates);
                }
            }
        }
        return _templater;
    } */
}
