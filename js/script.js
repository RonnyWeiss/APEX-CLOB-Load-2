var clobLoad = (function () {
    "use strict";
    var util = {
        featureDetails: {
            name: "APEX ClOB Load 2",
            scriptVersion: "1.5.4",
            utilVersion: "1.6",
            url: "https://github.com/RonnyWeiss",
            license: "MIT"
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
            return apex.util.escapeHTML(String(str));
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
                .replace(/&lt;/g, ">")
                .replace(/&gt;/g, ">")
                .replace(/&quot;/g, "\"")
                .replace(/#x27;/g, "'")
                .replace(/&#x2F;/g, "\\");
        },
        loader: {
            start: function (id, setMinHeight) {
                if (setMinHeight) {
                    $(id).css("min-height", "100px");
                }
                apex.util.showSpinner($(id));
            },
            stop: function (id, removeMinHeight) {
                if (removeMinHeight) {
                    $(id).css("min-height", "");
                }
                $(id + " > .u-Processing").remove();
                $(id + " > .ct-loader").remove();
            }
        },
        jsonSaveExtend: function (srcConfig, targetConfig) {
            var finalConfig = {};
            var tmpJSON = {};
            /* try to parse config json when string or just set */
            if (typeof targetConfig === 'string') {
                try {
                    tmpJSON = JSON.parse(targetConfig);
                } catch (e) {
                    apex.debug.error({
                        "module": "util.js",
                        "msg": "Error while try to parse targetConfig. Please check your Config JSON. Standard Config will be used.",
                        "err": e,
                        "targetConfig": targetConfig
                    });
                }
            } else {
                tmpJSON = $.extend(true, {}, targetConfig);
            }
            /* try to merge with standard if any attribute is missing */
            try {
                finalConfig = $.extend(true, {}, srcConfig, tmpJSON);
            } catch (e) {
                finalConfig = $.extend(true, {}, srcConfig);
                apex.debug.error({
                    "module": "util.js",
                    "msg": "Error while try to merge 2 JSONs into standard JSON if any attribute is missing. Please check your Config JSON. Standard Config will be used.",
                    "err": e,
                    "finalConfig": finalConfig
                });
            }
            return finalConfig;
        },
        splitString2Array: function (pString) {
            if (typeof pString !== "undefined" && pString !== null && pString != "" && pString.length > 0) {
                if (apex && apex.server && apex.server.chunk) {
                    return apex.server.chunk(pString);
                } else {
                    /* apex.server.chunk only avail on APEX 18.2+ */
                    var splitSize = 8000;
                    var tmpSplit;
                    var retArr = [];
                    if (pString.length > splitSize) {
                        for (retArr = [], tmpSplit = 0; tmpSplit < pString.length;) retArr.push(pString.substr(tmpSplit, splitSize)), tmpSplit += splitSize;
                        return retArr
                    }
                    retArr.push(pString);
                    return retArr;
                }
            } else {
                return [];
            }
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
            if (pValue && pValue.length > 0) {
                if (!pOpts.sanitize) {
                    str = pValue
                } else {
                    str = sanitizeCLOB(pValue, pOpts);
                }

                if (!pOpts.escapeHTML) {
                    if (pOpts.useURTEImgLoader) {
                        var div = $("<div></div>");
                        var items2SubmitImg = pOpts.items2SubmitImg;
                        try {
                            div.html(str);
                            var imgItems = div.find('img[alt*="aih#"]');
                            $.each(imgItems, function (idx, imgItem) {
                                var pk = imgItem.title;
                                if (!pk) {
                                    pk = imgItem.alt.split("aih##")[1];
                                }
                                if (pk) {
                                    var imgSRC = apex.server.pluginUrl(pOpts.ajaxID, {
                                        x01: "PRINT_IMAGE",
                                        x03: pk,
                                        pageItems: items2SubmitImg
                                    });
                                    imgItem.src = imgSRC;
                                } else {
                                    apex.debug.error({
                                        "fct": util.featureDetails.name + " - " + "setDomElement",
                                        "msg": "Primary key of img[alt*=\"aih#\"] is missing",
                                        "featureDetails": util.featureDetails
                                    });
                                }
                            });

                            /* force sub elements not to break out of the region*/
                            div
                                .find("*")
                                .css("max-width", "100%")
                                .css("overflow-wrap", "break-word")
                                .css("word-wrap", "break-word")
                                .css("-ms-hyphens", "auto")
                                .css("-moz-hyphens", "auto")
                                .css("-webkit-hyphens", "auto")
                                .css("hyphens", "auto")
                                .css("white-space", "normal");
                            div
                                .find("img")
                                .css("object-fit", "contain")
                                .css("object-position", "50% 0%");

                            $(pID).html(div[0].innerHTML);
                        } catch (e) {
                            apex.debug.error({
                                "fct": util.featureDetails.name + " - " + "setDomElement",
                                "msg": "Error while try to load images",
                                "err": e,
                                "featureDetails": util.featureDetails
                            });
                        }
                    } else {
                        $(pID).html(str);
                    }
                } else {
                    $(pID).text(str);
                }
                apex.event.trigger(pID, 'clobrendercomplete');
            }
        } else {
            apex.debug.error({
                "fct": util.featureDetails.name + " - " + "setDomElement",
                "msg": "No ELEMENT_SELECTOR set in SQL for CLOB Render",
                "featureDetails": util.featureDetails
            });
        }
    }

    /***********************************************************************
     **
     ** Used to set an item
     **
     ***********************************************************************/
    function setItem(pID, pValue, pOpts) {
        var str;
        var loaded = false;
        if (pID) {
            if (pValue && pValue.length > 0) {
                if (!pOpts.sanitize) {
                    str = pValue;
                } else {
                    str = sanitizeCLOB(pValue, pOpts);
                }

                if (pOpts.escapeHTML) {
                    str = util.escapeHTML(pValue);
                } else {
                    if (pOpts.useURTEImgLoader) {
                        var div = $("<div></div>");
                        var items2SubmitImg = pOpts.items2SubmitImg;
                        try {
                            div.html(str);
                            var imgItems = div.find('img[alt*="aih#"]');
                            $.each(imgItems, function (idx, imgItem) {
                                var pk = imgItem.title;
                                if (!pk) {
                                    pk = imgItem.alt.split("aih##")[1];
                                }
                                if (pk) {
                                    var pk = imgItem.title;
                                    var imgSRC = apex.server.pluginUrl(pOpts.ajaxID, {
                                        x01: "PRINT_IMAGE",
                                        x03: pk,
                                        pageItems: items2SubmitImg
                                    });
                                    imgItem.src = imgSRC;
                                } else {
                                    apex.debug.error({
                                        "fct": util.featureDetails.name + " - " + "setItem",
                                        "msg": "img in richtexteditor has no title. Title is used a primary key to get image from db.",

                                        "featureDetails": util.featureDetails
                                    });
                                }
                            });
                            str = div[0].innerHTML;
                        } catch (e) {
                            apex.debug.error({
                                "fct": util.featureDetails.name + " - " + "setItem",
                                "msg": "Error while try to load images when loading rich text editor.",
                                "err": e,
                                "featureDetails": util.featureDetails
                            });
                        }
                    }
                }

                if (apex.item(pID).item_type.indexOf("CKEDITOR") !== -1) {
                    CKEDITOR.on('instanceReady', function (ev) {
                        if (loaded !== true) {

                            apex.debug.info({
                                "fct": util.featureDetails.name + " - " + "setItem",
                                "msg": "CKEDITOR instanceReady fired",
                                "featureDetails": util.featureDetails
                            });

                            apex.item(pID).setValue(str);
                            CKEDITOR.instances[pID].on('contentDom', function () {
                                apex.event.trigger("#" + pID, 'clobrendercomplete');
                            });
                            loaded = true;
                        }
                    });
                    /* bad workaround if instance ready is not fired or this plugin loads to late. if u have a better idead please update */
                    setTimeout(function () {
                        if (loaded !== true) {

                            apex.debug.info({
                                "fct": util.featureDetails.name + " - " + "setItem",
                                "msg": "No Instance Ready event from CKEDITOR",
                                "featureDetails": util.featureDetails
                            });

                            apex.item(pID).setValue(str);
                            CKEDITOR.instances[pID].on('contentDom', function () {
                                apex.event.trigger("#" + pID, 'clobrendercomplete');
                            });
                            loaded = true;
                        }
                    }, 750);
                } else {
                    apex.item(pID).setValue(str);
                    apex.event.trigger("#" + pID, 'clobrendercomplete');
                }
            } else {
                apex.event.trigger("#" + pID, 'clobrendercomplete');
            }
        } else {
            apex.debug.error({
                "fct": util.featureDetails.name + " - " + "setItem",
                "msg": "No ELEMENT_SELECTOR set in SQL for CLOB Render",
                "featureDetails": util.featureDetails
            });
        }
    }

    /***********************************************************************
     **
     ** Used to print the clob value to the elements that are in data json
     **
     ***********************************************************************/
    function printClob(pData, pOpts, pThis) {
        try {
            if (pData.row && pData.row.length > 0) {
                $.each(pData.row, function (i, data) {
                    if (data.ELEMENT_SELECTOR && data.CLOB_VALUE) {
                        if (data.ELEMENT_TYPE) {
                            if (data.ELEMENT_TYPE == 'dom') {
                                setDomElement(data.ELEMENT_SELECTOR, data.CLOB_VALUE, pOpts);
                            } else if (data.ELEMENT_TYPE == 'item') {
                                setItem(data.ELEMENT_SELECTOR, data.CLOB_VALUE, pOpts);
                            } else {
                                apex.debug.error({
                                    "fct": util.featureDetails.name + " - " + "printClob",
                                    "msg": "ELEMENT_TYPE must be: dom, item and not " + data.ELEMENT_TYPE,
                                    "featureDetails": util.featureDetails
                                });
                            }
                        } else {
                            apex.debug.error({
                                "fct": util.featureDetails.name + " - " + "printClob",
                                "msg": "ELEMENT_TYPE is null in SQL for CLOB Render",
                                "featureDetails": util.featureDetails
                            });
                        }
                    }
                });
            }
            $.each(pOpts.affElements, function (i, element) {
                util.loader.stop(element);
                apex.event.trigger(element, 'clobrendercomplete');
            });
            apex.da.resume(pThis.resumeCallback, false);
        } catch (e) {
            apex.debug.error({
                "fct": util.featureDetails.name + " - " + "printClob",
                "msg": "Error while render CLOB",
                "err": e,
                "featureDetails": util.featureDetails
            });
            $.each(pOpts.affElements, function (i, element) {
                util.loader.stop(element);
                apex.event.trigger(element, 'clobrendererror');
            });
            apex.da.resume(pThis.resumeCallback, true);
        }
    }

    /***********************************************************************
     **
     ** Used to upload the clob value from an item to database
     **
     ***********************************************************************/
    function uploadClob(pOpts, pThis) {
        var clob = apex.item(pOpts.itemStoresCLOB).getValue();
        var items2Submit = pOpts.items2Submit;
        var collectionName = apex.item(pOpts.collectionNameItem).getValue();

        if (pOpts.unEscapeHTML) {
            clob = util.unEscapeHTML(clob);
        }

        if (pOpts.sanitize) {
            clob = sanitizeCLOB(clob, pOpts);
        }

        var chunkArr = util.splitString2Array(clob);

        apex.server.plugin(pOpts.ajaxID, {
            x01: pOpts.functionType,
            x02: collectionName,
            f01: chunkArr,
            pageItems: items2Submit
        }, {
            dataType: "text",
            success: function (pData) {
                $.each(pOpts.affElements, function (i, element) {
                    util.loader.stop(element);
                    apex.event.trigger(element, 'clobuploadcomplete');
                });
                apex.debug.info({
                    "fct": util.featureDetails.name + " - " + "uploadClob",
                    "msg": "Clob Upload successful",
                    "featureDetails": util.featureDetails
                });
                apex.da.resume(pThis.resumeCallback, false);
            },
            error: function (jqXHR, textStatus, errorThrown) {
                $.each(pOpts.affElements, function (i, element) {
                    util.loader.stop(element);
                    apex.event.trigger(element, 'clobuploaderror');
                });
                apex.debug.error({
                    "fct": util.featureDetails.name + " - " + "uploadClob",
                    "msg": "Clob Upload error",
                    "jqXHR": jqXHR,
                    "textStatus": textStatus,
                    "errorThrown": errorThrown,
                    "featureDetails": util.featureDetails
                });
                apex.da.resume(pThis.resumeCallback, true);
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

            apex.debug.info({
                "fct": util.featureDetails.name + " - " + "initialize",
                "arguments": {
                    "pThis": pThis,
                    "pOpts": pOpts
                },
                "featureDetails": util.featureDetails
            });
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

            if (opts.showLoader == 'Y') {
                opts.showLoader = true;
            } else {
                opts.showLoader = false;
            }

            if (opts.useURTEImgLoader == 'Y') {
                opts.useURTEImgLoader = true;
            } else {
                opts.useURTEImgLoader = false;
            }

            opts.affElements = [];

            /* get Arr of affected elements */
            if (pThis.affectedElements) {
                $.each(pThis.affectedElements, function (i, element) {
                    var elID = $(element).attr("id");
                    if (elID) {
                        opts.affElements.push("#" + elID);
                    }
                });
            }

            /* show loader when set */
            if (opts.showLoader) {
                $.each(opts.affElements, function (i, element) {
                    util.loader.start(element);
                });
            }

            /***********************************************************************
             **
             ** Used to get clob data when in print mode
             **
             ***********************************************************************/
            if (opts.functionType == 'PRINT_CLOB') {
                var items2Submit = opts.items2Submit;
                apex.server.plugin(
                    opts.ajaxID, {
                        x01: pOpts.functionType,
                        pageItems: items2Submit
                    }, {
                        success: function (pData) {
                            apex.debug.info({
                                "fct": util.featureDetails.name + " - " + "initialize",
                                "msg": "AJAX data received",
                                "pData": pData,
                                "featureDetails": util.featureDetails
                            });
                            printClob(pData, opts, pThis);
                        },
                        error: function (d) {
                            apex.debug.error({
                                "fct": util.featureDetails.name + " - " + "initialize",
                                "msg": "AJAX data error",
                                "response": d,
                                "featureDetails": util.featureDetails
                            });
                            $.each(opts.affElements, function (i, element) {
                                util.loader.stop(element);
                                apex.event.trigger(element, 'clobrendererror');
                            });
                            apex.da.resume(pThis.resumeCallback, true);
                        },
                        dataType: "json"
                    });
            } else {
                uploadClob(opts, pThis);
            }
        }
    }
})();
