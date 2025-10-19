/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.views.block;

mixin(Version!("test_uim_views"));

import uim.views;
@safe:

/* * ViewBlock : the concept of Blocks or Slots in the View layer.
 * Slots or blocks are combined with extending views and layouts to afford slots
 * of content that are present in a layout or parent view, but are defined by the child
 * view or elements used in the view.
 */
class DViewBlock {
    // Override content
    const string OVERRIDE = "override";

    // Append content
    const string APPEND = "append";

    // Prepend content
    const string PREPEND = "prepend";

    // Block content. An array of blocks indexed by name.
    protected STRINGAA _blocks;

    // The active blocks being captured.
    protected STRINGAA _activeBlocks;

    // Should the currently captured content be discarded on ViewBlock.end()
    protected bool _discardActiveBufferOnEnd = false;

    /**
     * Start capturing output for a "block"
     *
     * Blocks allow you to create slots or blocks of dynamic content in the layout.
     * view files can implement some or all of a layout"s slots.
     *
     * You can end capturing blocks using View.end(). Blocks can be output
     * using View.get();
     */
    void start(string blockName, string blockMode = DViewBlock.OVERRIDE) {
        if (_activeBlocks.hasKey(blockName)) {
            // TODO throw new UIMException("A view block with the name `%s` is already/still open.".format(blockName));
            return;
        }
        _activeBlocks[blockName] = blockMode;
        // TODO ob_start();
    }

    // End a capturing block. The compliment to ViewBlock.start()
    void end() {
        if (_discardActiveBufferOnEnd) {
            _discardActiveBufferOnEnd = false;
            // TODO ob_end_clean();

            return;
        }
        // TODO if (_activeBlocks.isNull) {
        // TODO     return;
        // TODO }

        string blockMode; // TODO = end(_activeBlocks);
        string activeKey; // TOD = key(_activeBlocks);
        string blockContent; // TODO ob_get_clean().to!string;
        if (blockMode == DViewBlock.OVERRIDE) {
            _blocks[activeKey] = blockContent;
        } else {
            this.concat(activeKey, blockContent, blockMode);
        }
        //TODO _activeBlocks.pop();
    }

    /**
     * Concat content to an existing or new block.
     * Concating to a new block will create the block.
     *
     * Calling concat() without a value will create a new capturing
     * block that needs to be finished with View.end(). The content
     * of the new capturing context will be added to the existing block context.
     */
    void concat(string blockName, string blockContent = null, string blockMode = DViewBlock.APPEND) {
        if (blockContent.isEmpty) {
            start(blockName, blockMode);

            return;
        }
        if (!_blocks.hasKey(blockName)) {
            _blocks[blockName] = "";
        }
        _blocks[blockName] = blockMode == DViewBlock.PREPEND
            ? blockContent ~ _blocks[blockName] : _blocks[blockName] ~ blockContent;

    }

    // Set the content for a block. This will overwrite any existing content.
    void set(string blockName, Json blockData) {
        set(blockName, blockData.toString);
    }

    void set(string blockName, string blockContent) {
        _blocks[blockName] = blockContent;
    }

    // Get the content for a block.
    string get(string blockName, string defaultContent = "") {
        return _blocks.get(blockName, defaultContent);
    }

    //Check if a block exists
    bool hasKey(string blockName) {
        return false; // TODO _blocks.hasKey(blockName);
    }

    // Get the names of all the existing blocks.
    string[] keys() {
        return _blocks.keys;
    }

    // Get the name of the currently open block.
    string active() {
        //TODO  end(_activeBlocks);

        return null; //TODO  key(_activeBlocks);
    }

    // Get the unclosed/active blocks. Key is name, value is mode.
    STRINGAA unclosedBlocks() {
        return _activeBlocks;
    }
}
