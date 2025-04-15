/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.classes.elements.colgroup;

mixin(Version!("test_uim_html"));

import uim.html;
@safe:

/* 
 * The <colgroup> element is used to group columns in a table for formatting purposes.
 * It can be used to apply styles to a group of columns, such as setting their width or background color.
 * The <colgroup> element can contain one or more <col> elements, which define the properties of each column in the group.
 * 
 * Example:
 * ```html
 * <table>
 *   <colgroup>
 *     <col style="background-color: yellow;">
 *     <col style="background-color: lightblue;">
 *   </colgroup>
 *   <tr>
 *     <td>Column 1</td>
 *     <td>Column 2</td>
 *   </tr>
 * </table>
 * ```
 */
class DH5Colgroup : DH5Obj {
	mixin(H5This!"Colgroup");
}
mixin(H5Short!"Colgroup");

unittest {
  testH5Obj(H5Colgroup, "colgroup");
}
