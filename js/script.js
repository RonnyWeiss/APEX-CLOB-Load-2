var clobLoad = (function () {
    "use strict";
    var scriptVersion = "1.2.2";
    var util = {
        version: "1.0.5",
        isAPEX: function () {
            if (typeof (apex) !== 'undefined') {
                return true;
            } else {
                return false;
            }
        },
        debug: {
            info: function (str) {
                if (util.isAPEX()) {
                    apex.debug.info(str);
                }
            },
            error: function (str) {
                if (util.isAPEX()) {
                    apex.debug.error(str);
                } else {
                    console.error(str);
                }
            }
        },
        escapeHTML: function (str) {
            if (str === null) {
                return null;
            }
            if (typeof str === "undefined") {
                return;
            }
            if (typeof str === "object") {
                try {
                    str = JSON.stringify(str);
                } catch (e) {
                    /*do nothing */
                }
            }
            if (util.isAPEX()) {
                return apex.util.escapeHTML(String(str));
            } else {
                str = String(str);
                return str
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;")
                    .replace(/"/g, "&quot;")
                    .replace(/'/g, "&#x27;")
                    .replace(/\//g, "&#x2F;");
            }
        },
        unEscapeHTML: function (str) {
            if (str === null) {
                return null;
            }
            if (typeof str === "undefined") {
                return;
            }
            if (typeof str === "object") {
                try {
                    str = JSON.stringify(str);
                } catch (e) {
                    /*do nothing */
                }
            }
            str = String(str);
            return str
                .replace(/&amp;/g, "&")
                .replace(/&lt;/g, "<")
                .replace(/&gt;/g, ">")
                .replace(/&quot;/g, "\"")
                .replace(/#x27;/g, "'")
                .replace(/&#x2F;/g, "\\");
        },
        loader: {
            start: function (id) {
                if (util.isAPEX()) {
                    apex.util.showSpinner($(id));
                } else {
                    /* define loader */
                    var faLoader = $("<span></span>");
                    faLoader.attr("id", "loader" + id);
                    faLoader.addClass("ct-loader");

                    /* define refresh icon with animation */
                    var faRefresh = $("<i></i>");
                    faRefresh.addClass("fa fa-refresh fa-2x fa-anim-spin");
                    faRefresh.css("background", "rgba(121,121,121,0.6)");
                    faRefresh.css("border-radius", "100%");
                    faRefresh.css("padding", "15px");
                    faRefresh.css("color", "white");

                    /* append loader */
                    faLoader.append(faRefresh);
                    $(id).append(faLoader);
                }
            },
            stop: function (id) {
                $(id + " > .u-Processing").remove();
                $(id + " > .ct-loader").remove();
            }
        },
        setItemValue: function (itemName, value) {
            if (util.isAPEX()) {
                if (apex.item(itemName) && apex.item(itemName).node != false) {
                    apex.item(itemName).setValue(value);
                } else {
                    console.error('Please choose a set item. Because the value (' + value + ') can not be set on item (' + itemName + ')');
                }
            } else {
                console.error("Error while try to call apex.item" + e);
            }
        },
        jsonSaveExtend: function (srcConfig, targetConfig) {
            var finalConfig = {};
            /* try to parse config json when string or just set */
            if (typeof targetConfig === 'string') {
                try {
                    targetConfig = JSON.parse(targetConfig);
                } catch (e) {
                    console.error("Error while try to parse targetConfig. Please check your Config JSON. Standard Config will be used.");
                    console.error(e);
                    console.error(targetConfig);
                }
            } else {
                finalConfig = targetConfig;
            }
            /* try to merge with standard if any attribute is missing */
            try {
                finalConfig = $.extend(true, srcConfig, targetConfig);
            } catch (e) {
                console.error('Error while try to merge 2 JSONs into standard JSON if any attribute is missing. Please check your Config JSON. Standard Config will be used.');
                console.error(e);
                finalConfig = srcConfig;
                console.error(finalConfig);
            }
            return finalConfig;
        }
    };

    /***********************************************************************
     **
     ** Used to sanitize HTML
     **
     ***********************************************************************/
    function sanitizeCLOB(pCLOB, pOpts) {
        return DOMPurify.sanitize(pCLOB, pOpts.sanitizeOptions);
    }

    /***********************************************************************
     **
     ** Used to set content of a dom element
     **
     ***********************************************************************/
    function setDomElement(pID, pValue, pOpts) {
        var str;
        if (pID) {
            $(pID).empty();

            if (!pOpts.sanitize) {
                str = pValue
            } else {
                str = sanitizeCLOB(pValue, pOpts);
            }

            if (!pOpts.escapeHTML) {
                $(pID).html(str);
            } else {
                $(pID).text(str);
            }
        } else {
            util.debug.error("No ELEMENT_SELECTOR set in SQL for CLOB Render");
        }
    }

    /***********************************************************************
     **
     ** Used to set an item
     **
     ***********************************************************************/
    function setItem(pID, pValue, pOpts) {
        var str;
        if (pID) {
            if (!pOpts.sanitize) {
                str = pValue;
            } else {
                str = sanitizeCLOB(pValue, pOpts);
            }

            if (pOpts.escapeHTML) {
                str = util.escapeHTML(pValue);
            }
            util.setItemValue(pID, str);
        } else {
            util.debug.error("No ELEMENT_SELECTOR set in SQL for CLOB Render");
        }
    }

    /***********************************************************************
     **
     ** Used to set an item when it's a rich text editor
     **
     ***********************************************************************/
    function setCKE(pID, pValue, pOpts) {
        var str;
        var loaded = false;

        if (pID) {
            if (!pOpts.sanitize) {
                str = pValue;
            } else {
                str = sanitizeCLOB(pValue, pOpts);
            }

            if (pOpts.escapeHTML) {
                str = util.escapeHTML(pValue);
            }

            CKEDITOR.on('instanceReady', function (ev) {
                util.debug.info("CKEDITOR instanceReady fired");
                util.setItemValue(pID, str);
                loaded = true;
            });
            /* bad workaround if instance ready is not fired. if u have a better idead please update */
            setTimeout(function () {
                if (loaded !== true) {
                    util.debug.info("No Instance Ready event from CKEDITOR");
                    util.setItemValue(pID, str);
                }
            }, 700);
        } else {
            util.debug.error("No ELEMENT_SELECTOR set in SQL for CLOB Render");
        }
    }

    /***********************************************************************
     **
     ** Used to print the clob value to the elements that are in data json
     **
     ***********************************************************************/
    function printClob(pData, pOpts, pThis) {
        try {

            util.debug.info(pData);

            if (pData.row && pData.row.length > 0) {
                $.each(pData.row, function (i, data) {
                    if (data.ELEMENT_SELECTOR && data.CLOB_VALUE) {
                        if (data.ELEMENT_TYPE) {
                            if (data.ELEMENT_TYPE == 'dom') {
                                setDomElement(data.ELEMENT_SELECTOR, data.CLOB_VALUE, pOpts);
                            } else if (data.ELEMENT_TYPE == 'item') {
                                setItem(data.ELEMENT_SELECTOR, data.CLOB_VALUE, pOpts);
                            } else if (data.ELEMENT_TYPE == 'richtext') {
                                setCKE(data.ELEMENT_SELECTOR, data.CLOB_VALUE, pOpts);
                            } else {
                                util.debug.error("ELEMENT_TYPE must be: dom, item or richtext and not " + data.ELEMENT_TYPE);
                            }
                        } else {
                            util.debug.error("ELEMENT_TYPE is null in SQL for CLOB Render");
                        }
                    }
                });
            }
            if (pOpts.showLoader == 'Y') {
                if (pThis.affectedElements) {
                    $.each(pThis.affectedElements, function (i, element) {
                        var elID = $(element).attr("id");
                        if (elID) {
                            util.loader.stop("#" + elID);
                        }
                        $(element).trigger('clobrendercomplete');
                    });
                }
            }
        } catch (e) {
            util.debug.error("Error while render CLOB");
            util.debug.error(e);
        }
    }

    /***********************************************************************
     **
     ** Used to upload the clob value from an item to database
     **
     ***********************************************************************/
    function uploadClob(pOpts, pThis) {
        var clob = apex.item(pOpts.itemStoresCLOB).getValue();

        if (pOpts.unEscapeHTML) {
            clob = util.unEscapeHTML(clob);
        }

        if (pOpts.sanitize) {
            clob = sanitizeCLOB(clob, pOpts);
        }

        var chunkArr = apex.server.chunk(clob);
        var collectionName = apex.item(pOpts.collectionNameItem).getValue();

        var items2Submit = pOpts.items2Submit;
        apex.server.plugin(pOpts.ajaxID, {
            x01: collectionName,
            f01: chunkArr,
            pageItems: items2Submit
        }, {
            dataType: "text",
            success: function (pData) {
                if (pThis.affectedElements) {
                    $.each(pThis.affectedElements, function (i, element) {
                        if (pOpts.showLoader == 'Y') {
                            var elID = $(element).attr("id");
                            if (elID) {
                                util.loader.stop("#" + elID);
                            }
                        }
                        $(element).trigger('clobuploadcomplete');
                    });
                }
                util.debug.info("Upload successful.");
            },
            error: function (jqXHR, textStatus, errorThrown) {
                util.debug.info("Upload error.");
                util.debug.error(jqXHR);
                util.debug.error(textStatus);
                util.debug.error(errorThrown);
            }
        });
    }

    /***********************************************************************
     **
     ** Init
     **
     ***********************************************************************/
    return {
        initialize: function (pThis, pOpts) {
            util.debug.info(pOpts);

            var opts = pOpts;

            var defaultSanitizeOptions = {
                "ALLOWED_ATTR": ["accesskey", "align", "alt", "always", "autocomplete", "autoplay", "border", "cellpadding", "cellspacing", "charset", "class", "dir", "height", "href", "id", "lang", "name", "rel", "required", "src", "style", "summary", "tabindex", "target", "title", "type", "value", "width"],
                "ALLOWED_TAGS": ["a", "address", "b", "blockquote", "br", "caption", "code", "dd", "div", "dl", "dt", "em", "figcaption", "figure", "h1", "h2", "h3", "h4", "h5", "h6", "hr", "i", "img", "label", "li", "nl", "ol", "p", "pre", "s", "span", "strike", "strong", "sub", "sup", "table", "tbody", "td", "th", "thead", "tr", "u", "ul"]
            };

            /* merge user defined sanitize options */
            opts.sanitizeOptions = util.jsonSaveExtend(defaultSanitizeOptions, pOpts.sanitizeOptions);

            /* Transfrom Yes/No Select List to Boolean */
            if (opts.sanitize == "N") {
                opts.sanitize = false;
            } else {
                opts.sanitize = true;
            }

            if (opts.escapeHTML == "N") {
                opts.escapeHTML = false;

            } else {
                opts.escapeHTML = true;
            }

            if (opts.unEscapeHTML == "N") {
                opts.unEscapeHTML = false;

            } else {
                opts.unEscapeHTML = true;
            }

            /* show loader when set */
            if (opts.showLoader == 'Y') {
                if (pThis.affectedElements) {
                    $.each(pThis.affectedElements, function (i, element) {
                        var elID = $(element).attr("id");
                        if (elID) {
                            util.loader.start("#" + elID);
                        }
                    });
                }
            }

            /***********************************************************************
             **
             ** Used to get clob data when in print mode
             **
             ***********************************************************************/
            if (opts.functionType == 'PRINT_CLOB') {
                var item2Submit = opts.items2Submit;
                apex.server.plugin(
                    opts.ajaxID, {
                        pageItems: item2Submit
                    }, {
                        success: function (pData) {
                            printClob(pData, opts, pThis);
                        },
                        error: function (d) {
                            util.debug.error(d.responseText);
                        },
                        dataType: "json"
                    });
            } else {
                uploadClob(opts, pThis);
            }
        }
    }
})();
