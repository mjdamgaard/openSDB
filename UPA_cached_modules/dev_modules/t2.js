
/* This module exports the function to initialize new content loaders and
 * make them wait for activation. (It will probably also export other functions
 * at some point..)
 **/


export function loadContent(jqObj) {
    // get the content key from the jQuery object, its id, and its context data.
    var contentKey = jqObj.attr("content-key");
    var id = jqObj.attr("id");
    var contextData = jqObj.attr("context-data");
    // look up the corresponding content loader function in a global variable
    // called upa1_contentLoaderFunctions.
    var clFun = upa1_contentLoaderFunctions[contentKey];
    // call the content loader function on the jQuery object and pass the
    // context data as input as well.
    clFun(jqObj, contextData);
    // after the content is loaded, search through the children to find any
    // nested content loaders, give them each unique ids (of the form
    // parentID + uniqueSuffix), and make them each listen for an event to
    // call this function for them as well.
    var idSuffix = 0;
    jqObj.find('[content-key]').each(function() {
        // set the id of the child content loader and increase idSuffix.
        let childID = id + "-" + idSuffix.toString();
        this.attr("id", childID);
        idSuffix += 1;
        // set up an event listener for the child to load its own content.
        this.on("Load content", function() {
            // load the inner content of child.
            loadContent(this);
        });
    });
    // trigger an event at the parent content loader to signal that the
    // children are ready.
    jqObj.trigger("Children are ready");
}
