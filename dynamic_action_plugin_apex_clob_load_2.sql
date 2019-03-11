prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_180200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2016.08.24'
,p_release=>'5.1.3.00.05'
,p_default_workspace_id=>21717127411908241868
,p_default_application_id=>103428
,p_default_owner=>'RD_DEV'
);
end;
/
prompt --application/shared_components/plugins/dynamic_action/apex_clob_load_2
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(64887869323691230468)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'APEX.CLOB.LOAD.2'
,p_display_name=>'APEX CLOB Load 2'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'PROCEDURE DOWNLOAD_FILE (',
'    P_IN_BLOB        BLOB,',
'    P_IN_FILE_NAME   VARCHAR2,',
'    P_IN_MIME_TYPE   VARCHAR2',
') AS',
'    VR_BLOB   BLOB := P_IN_BLOB;',
'BEGIN',
'    HTP.INIT;',
'    OWA_UTIL.MIME_HEADER(',
'        NVL(',
'            P_IN_MIME_TYPE,',
'            ''application/octet''',
'        ),',
'        FALSE,',
'        ''UTF-8''',
'    );',
'    HTP.P(''Content-length: '' || DBMS_LOB.GETLENGTH(P_IN_BLOB));',
'    HTP.P(''Content-Disposition: attachment; filename="'' ||',
'    P_IN_FILE_NAME || ''"'');',
'    OWA_UTIL.HTTP_HEADER_CLOSE;',
'    WPG_DOCLOAD.DOWNLOAD_FILE(VR_BLOB);',
'END;',
'',
'FUNCTION SQL_TO_SYS_REFCURSOR (',
'    P_IN_SQL_STATEMENT   CLOB,',
'    P_IN_BINDS           SYS.DBMS_SQL.VARCHAR2_TABLE',
') RETURN SYS_REFCURSOR AS',
'    VR_CURS         BINARY_INTEGER;',
'    VR_REF_CURSOR   SYS_REFCURSOR;',
'    VR_EXEC         BINARY_INTEGER;',
'/* TODO make size dynamic */',
'    VR_BINDS        VARCHAR(100);',
'BEGIN',
'    VR_CURS         := DBMS_SQL.OPEN_CURSOR;',
'    DBMS_SQL.PARSE(',
'        VR_CURS,',
'        P_IN_SQL_STATEMENT,',
'        DBMS_SQL.NATIVE',
'    );',
'    IF P_IN_BINDS.COUNT > 0 THEN',
'        FOR I IN 1..P_IN_BINDS.COUNT LOOP',
'/* TODO find out how to prevent ltrim */',
'            VR_BINDS   := LTRIM(',
'                P_IN_BINDS(I),',
'                '':''',
'            );',
'            DBMS_SQL.BIND_VARIABLE(',
'                VR_CURS,',
'                VR_BINDS,',
'                V(VR_BINDS)',
'            );',
'        END LOOP;',
'    END IF;',
'',
'    VR_EXEC         := DBMS_SQL.EXECUTE(VR_CURS);',
'    VR_REF_CURSOR   := DBMS_SQL.TO_REFCURSOR(VR_CURS);',
'    RETURN VR_REF_CURSOR;',
'EXCEPTION',
'    WHEN OTHERS THEN',
'        IF DBMS_SQL.IS_OPEN(VR_CURS) THEN',
'            DBMS_SQL.CLOSE_CURSOR(VR_CURS);',
'        END IF;',
'        RAISE;',
'END;',
'',
'FUNCTION F_AJAX (',
'    P_DYNAMIC_ACTION   IN                 APEX_PLUGIN.T_DYNAMIC_ACTION,',
'    P_PLUGIN           IN                 APEX_PLUGIN.T_PLUGIN',
') RETURN APEX_PLUGIN.T_DYNAMIC_ACTION_AJAX_RESULT IS',
'',
'    VR_RESULT            APEX_PLUGIN.T_DYNAMIC_ACTION_AJAX_RESULT;',
'    VR_CUR               SYS_REFCURSOR;',
'    VR_BIND_NAMES        SYS.DBMS_SQL.VARCHAR2_TABLE;',
'    VR_CLOB              CLOB := NULL;',
'    VR_TMP_STR           VARCHAR2(32767);',
'    VR_SQL               P_DYNAMIC_ACTION.ATTRIBUTE_01%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_01;',
'    VR_PLSQL_BLOCK       P_DYNAMIC_ACTION.ATTRIBUTE_07%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_07;',
'    VR_FUNCTION_TYPE     P_DYNAMIC_ACTION.ATTRIBUTE_04%TYPE := APEX_APPLICATION.G_X01;',
'    VR_COLLECTION_NAME   VARCHAR2(32767) := APEX_APPLICATION.G_X02;',
'    VR_PK                VARCHAR2(32767) := APEX_APPLICATION.G_X03;',
'    VR_FILE_NAME         VARCHAR2(200);',
'    VR_BLOB              BLOB;',
'    VR_MIME_TYPE         VARCHAR2(200);',
'    VR_USE_PRINT_IMG     P_DYNAMIC_ACTION.ATTRIBUTE_13%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_13;',
'    VR_PLSQL_PRINT_IMG   P_DYNAMIC_ACTION.ATTRIBUTE_14%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_14;',
'BEGIN',
'    CASE WHEN VR_FUNCTION_TYPE = ''PRINT_CLOB'' THEN',
'        /* undocumented function of APEX for get all bindings */',
'        VR_BIND_NAMES   := WWV_FLOW_UTILITIES.GET_BINDS(VR_SQL);',
'        VR_CUR          := SQL_TO_SYS_REFCURSOR(',
'            RTRIM(',
'                VR_SQL,',
'                '';''',
'            ),',
'            VR_BIND_NAMES',
'        );',
'',
'        /* create json */',
'        APEX_JSON.OPEN_OBJECT;',
'        APEX_JSON.WRITE(',
'            ''row'',',
'            VR_CUR',
'        );',
'        APEX_JSON.CLOSE_OBJECT;',
'',
'    WHEN VR_FUNCTION_TYPE = ''UPLOAD_CLOB'' THEN',
'        DBMS_LOB.CREATETEMPORARY(',
'            VR_CLOB,',
'            FALSE,',
'            DBMS_LOB.SESSION',
'        );',
'        FOR I IN 1..APEX_APPLICATION.G_F01.COUNT LOOP',
'            VR_TMP_STR   := WWV_FLOW.G_F01(I);',
'            IF LENGTH(VR_TMP_STR) > 0 THEN',
'                DBMS_LOB.WRITEAPPEND(',
'                    VR_CLOB,',
'                    LENGTH(VR_TMP_STR),',
'                    VR_TMP_STR',
'                );',
'            END IF;',
'',
'        END LOOP;',
'',
'        IF P_DYNAMIC_ACTION.ATTRIBUTE_06 = ''PLSQL'' THEN',
'            BEGIN',
'                EXECUTE IMMEDIATE ( VR_PLSQL_BLOCK )',
'                    USING VR_CLOB;',
'            EXCEPTION WHEN OTHERS THEN',
'                APEX_DEBUG.ERROR(''Error while executing dynamic PL/SQL Block after Upload CLOB.'');',
'                APEX_DEBUG.ERROR( DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );',
'            END;',
'            APEX_DEBUG.INFO(''Upload and Execute of Dynamic PL/SQL Block successful with CLOB: '' ||',
'            DBMS_LOB.GETLENGTH(VR_CLOB) ||',
'            '' Bytes.'');',
'        ELSE',
'            IF VR_COLLECTION_NAME IS NOT NULL THEN',
'                APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION(P_COLLECTION_NAME   => VR_COLLECTION_NAME);',
'                APEX_COLLECTION.ADD_MEMBER(',
'                    P_COLLECTION_NAME   => VR_COLLECTION_NAME,',
'                    P_CLOB001           => VR_CLOB',
'                );',
'            ELSE ',
'                APEX_DEBUG.ERROR(''Item that sotres collection name is null or does not exist.'');',
'            END IF;',
'            APEX_DEBUG.INFO(''Upload to Collection ('' ||',
'            VR_COLLECTION_NAME ||',
'            '') successful with CLOB: '' ||',
'            DBMS_LOB.GETLENGTH(VR_CLOB) ||',
'            '' Bytes.'');',
'        END IF;',
'    WHEN VR_FUNCTION_TYPE = ''PRINT_IMAGE'' AND VR_USE_PRINT_IMG = ''Y'' THEN',
'            BEGIN',
'                EXECUTE IMMEDIATE ( VR_PLSQL_PRINT_IMG )',
'                    USING IN VR_PK, OUT VR_FILE_NAME, OUT VR_MIME_TYPE, OUT VR_BLOB;',
'            EXCEPTION',
'                WHEN OTHERS THEN',
'                    APEX_DEBUG.ERROR(''Error while executing dynamic PL/SQL Block to get Blob Source for Image Download.'');',
'                    APEX_DEBUG.ERROR(SQLERRM);',
'                    APEX_DEBUG.ERROR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);',
'                    RAISE;',
'            END;',
'',
'            IF VR_FILE_NAME IS NOT NULL THEN',
'                DOWNLOAD_FILE(',
'                    P_IN_BLOB        => VR_BLOB,',
'                    P_IN_FILE_NAME   => VR_FILE_NAME,',
'                    P_IN_MIME_TYPE   => VR_MIME_TYPE',
'                );',
'            END IF;',
'',
'    ELSE ',
'        APEX_DEBUG.ERROR(''Function Type does not exists'');',
'    END CASE;',
'',
'    RETURN VR_RESULT;',
'END;',
'',
'FUNCTION F_RENDER (',
'    P_DYNAMIC_ACTION   IN                 APEX_PLUGIN.T_DYNAMIC_ACTION,',
'    P_PLUGIN           IN                 APEX_PLUGIN.T_PLUGIN',
') RETURN APEX_PLUGIN.T_DYNAMIC_ACTION_RENDER_RESULT IS',
'',
'    VR_RESULT             APEX_PLUGIN.T_DYNAMIC_ACTION_RENDER_RESULT;',
'    VR_FUNCTION_TYPE      P_DYNAMIC_ACTION.ATTRIBUTE_04%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_04;',
'    VR_ITEMS_2_SUBMIT     P_DYNAMIC_ACTION.ATTRIBUTE_02%TYPE := APEX_PLUGIN_UTIL.PAGE_ITEM_NAMES_TO_JQUERY(P_DYNAMIC_ACTION.ATTRIBUTE_02);',
'    VR_ESCAPE_HTML        P_DYNAMIC_ACTION.ATTRIBUTE_03%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_03;',
'    VR_SHOW_LOADER        P_DYNAMIC_ACTION.ATTRIBUTE_05%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_05;',
'    VR_COLLECTION_NAME    P_DYNAMIC_ACTION.ATTRIBUTE_08%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_08;',
'    VR_ITEMS_STORE_CLOB   P_DYNAMIC_ACTION.ATTRIBUTE_09%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_09;',
'    VR_SANITIZE_HTML      P_DYNAMIC_ACTION.ATTRIBUTE_10%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_10;',
'    VR_SANITIZE_HTML_OPT  P_DYNAMIC_ACTION.ATTRIBUTE_11%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_11;',
'    VR_UN_ESCAPE_HTML     P_DYNAMIC_ACTION.ATTRIBUTE_12%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_12;',
'    VR_USE_URTE_IMG_LOAD  P_DYNAMIC_ACTION.ATTRIBUTE_13%TYPE := P_DYNAMIC_ACTION.ATTRIBUTE_13;',
'    VR_ITEMS_2_SUBMIT_IMG P_DYNAMIC_ACTION.ATTRIBUTE_15%TYPE := APEX_PLUGIN_UTIL.PAGE_ITEM_NAMES_TO_JQUERY(P_DYNAMIC_ACTION.ATTRIBUTE_15);',
'BEGIN',
'    APEX_JAVASCRIPT.ADD_LIBRARY(',
'        P_NAME        => ''clobload.pkgd.min'',',
'        P_DIRECTORY   => P_PLUGIN.FILE_PREFIX,',
'        P_VERSION     => NULL,',
'        P_KEY         => ''clobload2jssrc''',
'    );',
'',
'    VR_RESULT.JAVASCRIPT_FUNCTION   := ''function () { var self = this; clobLoad.initialize( self, { '' ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''ajaxID'',',
'        APEX_PLUGIN.GET_AJAX_IDENTIFIER',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''functionType'',',
'        VR_FUNCTION_TYPE',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''items2Submit'',',
'        VR_ITEMS_2_SUBMIT',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''items2SubmitImg'',',
'        VR_ITEMS_2_SUBMIT_IMG',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''itemStoresCLOB'',',
'        VR_ITEMS_STORE_CLOB',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''escapeHTML'',',
'        VR_ESCAPE_HTML',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''unEscapeHTML'',',
'        VR_UN_ESCAPE_HTML',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''sanitize'',',
'        VR_SANITIZE_HTML',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''sanitizeOptions'',',
'        VR_SANITIZE_HTML_OPT',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''collectionNameItem'',',
'        VR_COLLECTION_NAME',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''useURTEImgLoader'',',
'        VR_USE_URTE_IMG_LOAD',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''showLoader'',',
'        VR_SHOW_LOADER,',
'        TRUE,',
'        FALSE',
'    ) ||',
'    ''}); }'';',
'',
'    RETURN VR_RESULT;',
'END F_RENDER;'))
,p_api_version=>2
,p_render_function=>'F_RENDER'
,p_ajax_function=>'F_AJAX'
,p_standard_attributes=>'REGION'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'This plug-in can load clob data to any DOM element or Item on the APEX page, including also the RichTextEditor (CKE).',
'It''s also possible to upload a CLOB value again to the database. This value is stored in APEX Collection or it''s also possible that this plug-ins calls a PL/SQL API e.g. to write the CLOB into table after upload.',
'You can set Affected Element this is the element where any Dynamic Action Event is fired on and where the loader icon is shown.',
'When you want to get content of collection when submit page. Call the Upload with Dynamic Action "Before Page Submit".'))
,p_version_identifier=>'1.3.2'
,p_about_url=>'https://github.com/RonnyWeiss/APEX-CLOB-Load-2'
,p_files_version=>115
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(64888077816583242827)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'SQL Source'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
'    /* Element type dom - for jQuery selector e.g. body or #region-id, item - for item name e.g. P1_MY_ITEM */',
'    ''dom'' AS ELEMENT_TYPE,',
'    /* jQuery selector or item name */',
'    ''body'' AS ELEMENT_SELECTOR,',
'    /* CLOB value */',
'    TO_CLOB(''The CLOB Loader has replaced your body please set another element where CLOB should be loaded ;)'') AS CLOB_VALUE',
'FROM',
'    DUAL'))
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(64889111543858328993)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PRINT_CLOB'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'SELECT',
'    ''item'' AS ELEMENT_TYPE,',
'    ''P1_ITEM'' AS ELEMENT_SELECTOR,',
'    TO_CLOB(''Hello World'') AS CLOB_VALUE',
'FROM',
'    DUAL',
'UNION ALL',
'SELECT',
'    ''dom'' AS ELEMENT_TYPE,',
'    ''body'' AS ELEMENT_SELECTOR,',
'    TO_CLOB(''The CLOB Loader has replaced your body please set another element where CLOB should be loaded ;)'') AS CLOB_VALUE',
'FROM',
'    DUAL',
'</pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Since this plug-in can load multiple elements once, the element, the type and the CLOB must be specified in the SQL statement. Each line thus loads one element with CLOB.',
'',
'An example:',
'<pre>',
'SELECT',
'    /* Element type dom - for jQuery selector e.g. body or #region-id, item - for item name e.g. P1_MY_ITEM */',
'    ''dom'' AS ELEMENT_TYPE,',
'    /* jQuery selector or item name */',
'    ''body'' AS ELEMENT_SELECTOR,',
'    /* CLOB value */',
'    TO_CLOB(''The CLOB Loader has replaced your body please set another element where CLOB should be loaded ;)'') AS CLOB_VALUE',
'FROM',
'    DUAL',
'</pre>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(64888081939517244954)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>100
,p_prompt=>'Items to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Items that should be submited in each ajax call when upload or render CLOB.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(64888107445441248127)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>110
,p_prompt=>'Escape special Characters'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(64889111543858328993)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PRINT_CLOB'
,p_help_text=>'Select if special characters should be escaped in Render Mode.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(64889111543858328993)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>1
,p_prompt=>'Function Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'PRINT_CLOB'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'This attribute is used to set whether the plug-in should work as CLOB renderer or as CLOB uploader.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(64889112262803330039)
,p_plugin_attribute_id=>wwv_flow_api.id(64889111543858328993)
,p_display_sequence=>10
,p_display_value=>'Print CLOBs'
,p_return_value=>'PRINT_CLOB'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(64889084023559329358)
,p_plugin_attribute_id=>wwv_flow_api.id(64889111543858328993)
,p_display_sequence=>20
,p_display_value=>'Upload CLOB'
,p_return_value=>'UPLOAD_CLOB'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(64907304998948820954)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>300
,p_prompt=>'Show Loader Icon'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'If selected then loader icon is shown on affected element. The Dynamic Action Events of this plugin is also fired on the affcted element.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(65092609627234568211)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>20
,p_prompt=>'Upload to'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'COLLECTION'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(64889111543858328993)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'UPLOAD_CLOB'
,p_lov_type=>'STATIC'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Select if you want to Upload to a collection or if you want to execute PL/SQL.',
'',
'When you want to get content of collection when submit page. Call the Upload with Dynamic Action and event: Before Page Submit.'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(65093075846950569404)
,p_plugin_attribute_id=>wwv_flow_api.id(65092609627234568211)
,p_display_sequence=>10
,p_display_value=>'Collection'
,p_return_value=>'COLLECTION'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(65093077372835570954)
,p_plugin_attribute_id=>wwv_flow_api.id(65092609627234568211)
,p_display_sequence=>20
,p_display_value=>'Execute PL/SQL'
,p_return_value=>'PLSQL'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(65093110937260575331)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Execute PL/SQL'
,p_attribute_type=>'PLSQL'
,p_is_required=>true
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'    VR_COL_NAME   VARCHAR2(100) := NVL( V(''P1_COLLECTION_NAME''), ''MY_COLLECTION'');',
'BEGIN',
'    APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION(P_COLLECTION_NAME   => VR_COL_NAME);',
'    APEX_COLLECTION.ADD_MEMBER(',
'        P_COLLECTION_NAME   => VR_COL_NAME,',
'        P_CLOB001           => :CLOB',
'    );',
'END;'))
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(65092609627234568211)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PLSQL'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>You can execute dynamic PL/SQL when upload a CLOB.</p>',
'<p>Important is that you use the binding :CLOB for this binding the uploaded CLOB is set.</p>',
'<p>When want to use APEX items you have to call V(''P1_ITEM'') because of binding and add the items in "Items to Submit". Use (SELECT V(''P1_ITEM'') FROM DUAL) for better perfromance when use in SQL Statement => See Oracle FAST_DUAL.</p>',
'<pre>',
'DECLARE',
'    VR_COL_NAME   VARCHAR2(100) := NVL( V(''P1_COLLECTION_NAME''), ''MY_COLLECTION'');',
'BEGIN',
'    APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION(P_COLLECTION_NAME   => VR_COL_NAME);',
'    APEX_COLLECTION.ADD_MEMBER(',
'        P_COLLECTION_NAME   => VR_COL_NAME,',
'        P_CLOB001           => :CLOB',
'    );',
'END;',
'</pre>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(65093116893542578898)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Item stores Collection Name'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(65092609627234568211)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'COLLECTION'
,p_help_text=>'Select an Item that stores the collection name.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(65098289181115760948)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Item stores CLOB Value'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(64889111543858328993)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'UPLOAD_CLOB'
,p_help_text=>'Choose the item from which you want to upload the CLOB.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(65248331910942932540)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>130
,p_prompt=>'Sanitize HTML'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'Sanitizes HTML e.g. &lt;script&gt; tags will be removed.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(65253615032891334010)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>140
,p_prompt=>'Sanitize HTML Options'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>true
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'{',
'  "ALLOWED_ATTR": [',
'    "accesskey",',
'    "align",',
'    "alt",',
'    "always",',
'    "autocomplete",',
'    "autoplay",',
'    "border",',
'    "cellpadding",',
'    "cellspacing",',
'    "charset",',
'    "class",',
'    "dir",',
'    "height",',
'    "href",',
'    "id",',
'    "lang",',
'    "name",',
'    "rel",',
'    "required",',
'    "src",',
'    "style",',
'    "summary",',
'    "tabindex",',
'    "target",',
'    "title",',
'    "type",',
'    "value",',
'    "width"',
'  ],',
'  "ALLOWED_TAGS": [',
'    "a",',
'    "address",',
'    "b",',
'    "blockquote",',
'    "br",',
'    "caption",',
'    "code",',
'    "dd",',
'    "div",',
'    "dl",',
'    "dt",',
'    "em",',
'    "figcaption",',
'    "figure",',
'    "h1",',
'    "h2",',
'    "h3",',
'    "h4",',
'    "h5",',
'    "h6",',
'    "hr",',
'    "i",',
'    "img",',
'    "label",',
'    "li",',
'    "nl",',
'    "ol",',
'    "p",',
'    "pre",',
'    "s",',
'    "span",',
'    "strike",',
'    "strong",',
'    "sub",',
'    "sup",',
'    "table",',
'    "tbody",',
'    "td",',
'    "th",',
'    "thead",',
'    "tr",',
'    "u",',
'    "ul"',
'  ]',
'}'))
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(65248331910942932540)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'This Clob Loader includes a sanitizer for HTML as option to use:',
'A Full Description you will find on: https://github.com/cure53/DOMPurify',
'Example: ',
'<pre>',
'{',
'  "ALLOWED_ATTR": [',
'    "accesskey",',
'    "align",',
'    "alt",',
'    "always",',
'    "autocomplete",',
'    "autoplay",',
'    "border",',
'    "cellpadding",',
'    "cellspacing",',
'    "charset",',
'    "class",',
'    "dir",',
'    "height",',
'    "href",',
'    "id",',
'    "lang",',
'    "name",',
'    "rel",',
'    "required",',
'    "src",',
'    "style",',
'    "summary",',
'    "tabindex",',
'    "target",',
'    "title",',
'    "type",',
'    "value",',
'    "width"',
'  ],',
'  "ALLOWED_TAGS": [',
'    "a",',
'    "address",',
'    "b",',
'    "blockquote",',
'    "br",',
'    "caption",',
'    "code",',
'    "dd",',
'    "div",',
'    "dl",',
'    "dt",',
'    "em",',
'    "figcaption",',
'    "figure",',
'    "h1",',
'    "h2",',
'    "h3",',
'    "h4",',
'    "h5",',
'    "h6",',
'    "hr",',
'    "i",',
'    "img",',
'    "label",',
'    "li",',
'    "nl",',
'    "ol",',
'    "p",',
'    "pre",',
'    "s",',
'    "span",',
'    "strike",',
'    "strong",',
'    "sub",',
'    "sup",',
'    "table",',
'    "tbody",',
'    "td",',
'    "th",',
'    "thead",',
'    "tr",',
'    "u",',
'    "ul"',
'  ]',
'}',
'</pre>',
'<pre>',
'# make output safe for usage in jQuery''s $()/html() method (default is false)',
'SAFE_FOR_JQUERY: true',
'',
'# strip {{ ... }} and &amp;lt;% ... %&amp;gt; to make output safe for template systems',
'# be careful please, this mode is not recommended for production usage.',
'# allowing template parsing in user-controlled HTML is not advised at all.',
'# only use this mode if there is really no alternative.',
'SAFE_FOR_TEMPLATES: true',
'',
'# allow only &amp;lt;b&amp;gt;',
'ALLOWED_TAGS: [''b'']',
'',
'# allow only &amp;lt;b&amp;gt; and &amp;lt;q&amp;gt; with style attributes (for whatever reason)',
'ALLOWED_TAGS: [''b'', ''q''], ALLOWED_ATTR: [''style'']',
'',
'# allow all safe HTML elements but neither SVG nor MathML',
'USE_PROFILES: {html: true}',
'',
'# allow all safe SVG elements and SVG Filters',
'USE_PROFILES: {svg: true, svgFilters: true}',
'',
'# allow all safe MathML elements and SVG',
'USE_PROFILES: {mathMl: true, svg: true}',
'',
'# leave all as it is but forbid &amp;lt;style&amp;gt;',
'FORBID_TAGS: [''style'']',
'',
'# leave all as it is but forbid style attributes',
'FORBID_ATTR: [''style'']',
'',
'# extend the existing array of allowed tags',
'ADD_TAGS: [''my-tag'']',
'',
'# extend the existing array of attributes',
'ADD_ATTR: [''my-attr'']',
'',
'# prohibit HTML5 data attributes (default is true)',
'ALLOW_DATA_ATTR: false',
'',
'# allow external protocol handlers in URL attributes (default is false)',
'# by default only http, https, ftp, ftps, tel, mailto, callto, cid and xmpp are allowed.',
'ALLOW_UNKNOWN_PROTOCOLS: true',
'</pre>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(65274423120505254413)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_prompt=>'Unescape special Characters'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(64889111543858328993)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'UPLOAD_CLOB'
,p_help_text=>'Unescapes HTML when upload to save it as HTML in DB.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(34039670856858875009)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>200
,p_prompt=>'Use Image Loader of Unleash RichTextEditor Plug-in'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(64889111543858328993)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PRINT_CLOB'
,p_help_text=>'Use Image Loader of Unleash RichTextEditor Plug-in. Tihs feature is usefull when u are using this plugin and have img tags that where created with that plugin in your clob.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(34039961652706884751)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>210
,p_prompt=>'Execute to get Image Sources'
,p_attribute_type=>'PLSQL'
,p_is_required=>true
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'    VR_FILE_NAME     VARCHAR2(200);',
'    VR_MIME_TYPE     VARCHAR2(200);',
'    VR_BINARY_FILE   BLOB;',
'    VR_PK            VARCHAR2(200) := :PK;',
'    VR_COL_NAME      VARCHAR2(200) := NVL(',
'        V(''P1_COL_NAME''),',
'        ''IMG_COLLECTION''',
'    );',
'BEGIN',
'    SELECT',
'        C001,',
'        C002,',
'        BLOB001',
'    INTO',
'        VR_FILE_NAME,',
'        VR_MIME_TYPE,',
'        VR_BINARY_FILE',
'    FROM',
'        APEX_COLLECTIONS',
'    WHERE',
'        COLLECTION_NAME   = VR_COL_NAME',
'        AND C001              = VR_PK',
'        AND ROWNUM            = 1;',
'',
'    :FILE_NAME     := VR_FILE_NAME;',
'    :MIME_TYPE     := VR_MIME_TYPE;',
'    :BINARY_FILE   := VR_BINARY_FILE;',
'EXCEPTION',
'    WHEN OTHERS THEN',
'        APEX_DEBUG.ERROR(SQLERRM);',
'        APEX_DEBUG.ERROR(DBMS_UTILITY.FORMAT_ERROR_STACK);',
'END;'))
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(34039670856858875009)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>If the CLOB is loaded into the RTE, the image download is inserted on the left.</p>',
'<p>This PL/SQL block is used to load the images from a table or collection using a primary key (:PK).</p>',
'<p>On Error please check APEX Debug. When want to use APEX items you have to call V(''P1_ITEM'') because of binding and add the items in "Items to Submit".</p>',
'<p>Use (SELECT V(''P1_ITEM'') FROM DUAL) for better perfromance when use in SQL Statement => See Oracle FAST_DUAL.</p>',
'<pre>',
'DECLARE',
'    VR_FILE_NAME     VARCHAR2(200);',
'    VR_MIME_TYPE     VARCHAR2(200);',
'    VR_BINARY_FILE   BLOB;',
'    VR_PK            VARCHAR2(200) := :PK;',
'    VR_COL_NAME      VARCHAR2(200) := NVL(',
'        V(''P1_COL_NAME''),',
'        ''IMG_COLLECTION''',
'    );',
'BEGIN',
'    SELECT',
'        C001,',
'        C002,',
'        BLOB001',
'    INTO',
'        VR_FILE_NAME,',
'        VR_MIME_TYPE,',
'        VR_BINARY_FILE',
'    FROM',
'        APEX_COLLECTIONS',
'    WHERE',
'        COLLECTION_NAME   = VR_COL_NAME',
'        AND C001              = VR_PK',
'        AND ROWNUM            = 1;',
'',
'    :FILE_NAME     := VR_FILE_NAME;',
'    :MIME_TYPE     := VR_MIME_TYPE;',
'    :BINARY_FILE   := VR_BINARY_FILE;',
'EXCEPTION',
'    WHEN OTHERS THEN',
'        APEX_DEBUG.ERROR(SQLERRM);',
'        APEX_DEBUG.ERROR(DBMS_UTILITY.FORMAT_ERROR_STACK);',
'END;',
'</pre>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(34233461393438296736)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>220
,p_prompt=>'Items to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(34039670856858875009)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Items that should be submitted for Image Loader.</p>',
'<b>Because of missing APEX feature no item with checksum can be used here.</b>'))
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(65162376116795094470)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_name=>'clobrendercomplete'
,p_display_name=>'CLOB Render Complete'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(65162375796453094468)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_name=>'clobuploadcomplete'
,p_display_name=>'CLOB Upload Complete'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '4D4954204C6963656E73650A0A436F7079726967687420286329203230313920526F6E6E792057656973730A0A5065726D697373696F6E20697320686572656279206772616E7465642C2066726565206F66206368617267652C20746F20616E79207065';
wwv_flow_api.g_varchar2_table(2) := '72736F6E206F627461696E696E67206120636F70790A6F66207468697320736F66747761726520616E64206173736F63696174656420646F63756D656E746174696F6E2066696C657320287468652022536F66747761726522292C20746F206465616C0A';
wwv_flow_api.g_varchar2_table(3) := '696E2074686520536F66747761726520776974686F7574207265737472696374696F6E2C20696E636C7564696E6720776974686F7574206C696D69746174696F6E20746865207269676874730A746F207573652C20636F70792C206D6F646966792C206D';
wwv_flow_api.g_varchar2_table(4) := '657267652C207075626C6973682C20646973747269627574652C207375626C6963656E73652C20616E642F6F722073656C6C0A636F70696573206F662074686520536F6674776172652C20616E6420746F207065726D697420706572736F6E7320746F20';
wwv_flow_api.g_varchar2_table(5) := '77686F6D2074686520536F6674776172652069730A6675726E697368656420746F20646F20736F2C207375626A65637420746F2074686520666F6C6C6F77696E6720636F6E646974696F6E733A0A0A5468652061626F766520636F70797269676874206E';
wwv_flow_api.g_varchar2_table(6) := '6F7469636520616E642074686973207065726D697373696F6E206E6F74696365207368616C6C20626520696E636C7564656420696E20616C6C0A636F70696573206F72207375627374616E7469616C20706F7274696F6E73206F662074686520536F6674';
wwv_flow_api.g_varchar2_table(7) := '776172652E0A0A54484520534F4654574152452049532050524F564944454420224153204953222C20574954484F55542057415252414E5459204F4620414E59204B494E442C2045585052455353204F520A494D504C4945442C20494E434C5544494E47';
wwv_flow_api.g_varchar2_table(8) := '20425554204E4F54204C494D4954454420544F205448452057415252414E54494553204F46204D45524348414E544142494C4954592C0A4649544E45535320464F52204120504152544943554C415220505552504F534520414E44204E4F4E494E465249';
wwv_flow_api.g_varchar2_table(9) := '4E47454D454E542E20494E204E4F204556454E54205348414C4C205448450A415554484F5253204F5220434F5059524947485420484F4C44455253204245204C4941424C4520464F5220414E5920434C41494D2C2044414D41474553204F52204F544845';
wwv_flow_api.g_varchar2_table(10) := '520A4C494142494C4954592C205748455448455220494E20414E20414354494F4E204F4620434F4E54524143542C20544F5254204F52204F54484552574953452C2041524953494E472046524F4D2C0A4F5554204F46204F5220494E20434F4E4E454354';
wwv_flow_api.g_varchar2_table(11) := '494F4E20574954482054484520534F465457415245204F522054484520555345204F52204F54484552204445414C494E475320494E205448450A534F4654574152452E0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(65166757879076426088)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_file_name=>'LICENSE'
,p_mime_type=>'application/octet-stream'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '68747470733A2F2F6769746875622E636F6D2F6375726535332F444F4D5075726966790D0A0D0A444F4D5075726966790D0A436F707972696768742032303135204D6172696F204865696465726963680D0A0D0A444F4D50757269667920697320667265';
wwv_flow_api.g_varchar2_table(2) := '6520736F6674776172653B20796F752063616E2072656469737472696275746520697420616E642F6F72206D6F6469667920697420756E646572207468650D0A7465726D73206F66206569746865723A0D0A0D0A61292074686520417061636865204C69';
wwv_flow_api.g_varchar2_table(3) := '63656E73652056657273696F6E20322E302C206F720D0A622920746865204D6F7A696C6C61205075626C6963204C6963656E73652056657273696F6E20322E300D0A0D0A2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D';
wwv_flow_api.g_varchar2_table(4) := '2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A0D0A4C6963656E73656420756E6465722074686520417061636865204C6963656E73652C2056657273696F6E20322E302028746865';
wwv_flow_api.g_varchar2_table(5) := '20224C6963656E736522293B0D0A796F75206D6179206E6F742075736520746869732066696C652065786365707420696E20636F6D706C69616E6365207769746820746865204C6963656E73652E0D0A596F75206D6179206F627461696E206120636F70';
wwv_flow_api.g_varchar2_table(6) := '79206F6620746865204C6963656E73652061740D0A0D0A20202020687474703A2F2F7777772E6170616368652E6F72672F6C6963656E7365732F4C4943454E53452D322E300D0A0D0A20202020556E6C657373207265717569726564206279206170706C';
wwv_flow_api.g_varchar2_table(7) := '696361626C65206C6177206F722061677265656420746F20696E2077726974696E672C20736F6674776172650D0A20202020646973747269627574656420756E64657220746865204C6963656E7365206973206469737472696275746564206F6E20616E';
wwv_flow_api.g_varchar2_table(8) := '20224153204953222042415349532C0D0A20202020574954484F55542057415252414E54494553204F5220434F4E444954494F4E53204F4620414E59204B494E442C206569746865722065787072657373206F7220696D706C6965642E0D0A2020202053';
wwv_flow_api.g_varchar2_table(9) := '656520746865204C6963656E736520666F7220746865207370656369666963206C616E677561676520676F7665726E696E67207065726D697373696F6E7320616E640D0A202020206C696D69746174696F6E7320756E64657220746865204C6963656E73';
wwv_flow_api.g_varchar2_table(10) := '652E0D0A0D0A2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D0D0A4D6F7A696C6C61205075626C696320';
wwv_flow_api.g_varchar2_table(11) := '4C6963656E73652C2076657273696F6E20322E300D0A0D0A312E20446566696E6974696F6E730D0A0D0A312E312E2093436F6E7472696275746F72940D0A0D0A20202020206D65616E73206561636820696E646976696475616C206F72206C6567616C20';
wwv_flow_api.g_varchar2_table(12) := '656E74697479207468617420637265617465732C20636F6E747269627574657320746F207468650D0A20202020206372656174696F6E206F662C206F72206F776E7320436F766572656420536F6674776172652E0D0A0D0A312E322E2093436F6E747269';
wwv_flow_api.g_varchar2_table(13) := '6275746F722056657273696F6E940D0A0D0A20202020206D65616E732074686520636F6D62696E6174696F6E206F662074686520436F6E747269627574696F6E73206F66206F74686572732028696620616E7929207573656420627920610D0A20202020';
wwv_flow_api.g_varchar2_table(14) := '20436F6E7472696275746F7220616E64207468617420706172746963756C617220436F6E7472696275746F72927320436F6E747269627574696F6E2E0D0A0D0A312E332E2093436F6E747269627574696F6E940D0A0D0A20202020206D65616E7320436F';
wwv_flow_api.g_varchar2_table(15) := '766572656420536F667477617265206F66206120706172746963756C617220436F6E7472696275746F722E0D0A0D0A312E342E2093436F766572656420536F667477617265940D0A0D0A20202020206D65616E7320536F7572636520436F646520466F72';
wwv_flow_api.g_varchar2_table(16) := '6D20746F2077686963682074686520696E697469616C20436F6E7472696275746F7220686173206174746163686564207468650D0A20202020206E6F7469636520696E204578686962697420412C207468652045786563757461626C6520466F726D206F';
wwv_flow_api.g_varchar2_table(17) := '66207375636820536F7572636520436F646520466F726D2C20616E640D0A20202020204D6F64696669636174696F6E73206F66207375636820536F7572636520436F646520466F726D2C20696E2065616368206361736520696E636C7564696E6720706F';
wwv_flow_api.g_varchar2_table(18) := '7274696F6E730D0A202020202074686572656F662E0D0A0D0A312E352E2093496E636F6D70617469626C652057697468205365636F6E64617279204C6963656E736573940D0A20202020206D65616E730D0A0D0A2020202020612E207468617420746865';
wwv_flow_api.g_varchar2_table(19) := '20696E697469616C20436F6E7472696275746F722068617320617474616368656420746865206E6F746963652064657363726962656420696E0D0A202020202020202045786869626974204220746F2074686520436F766572656420536F667477617265';
wwv_flow_api.g_varchar2_table(20) := '3B206F720D0A0D0A2020202020622E20746861742074686520436F766572656420536F66747761726520776173206D61646520617661696C61626C6520756E64657220746865207465726D73206F662076657273696F6E0D0A2020202020202020312E31';
wwv_flow_api.g_varchar2_table(21) := '206F72206561726C696572206F6620746865204C6963656E73652C20627574206E6F7420616C736F20756E64657220746865207465726D73206F6620610D0A20202020202020205365636F6E64617279204C6963656E73652E0D0A0D0A312E362E209345';
wwv_flow_api.g_varchar2_table(22) := '786563757461626C6520466F726D940D0A0D0A20202020206D65616E7320616E7920666F726D206F662074686520776F726B206F74686572207468616E20536F7572636520436F646520466F726D2E0D0A0D0A312E372E20934C617267657220576F726B';
wwv_flow_api.g_varchar2_table(23) := '940D0A0D0A20202020206D65616E73206120776F726B207468617420636F6D62696E657320436F766572656420536F6674776172652077697468206F74686572206D6174657269616C2C20696E20612073657061726174650D0A202020202066696C6520';
wwv_flow_api.g_varchar2_table(24) := '6F722066696C65732C2074686174206973206E6F7420436F766572656420536F6674776172652E0D0A0D0A312E382E20934C6963656E7365940D0A0D0A20202020206D65616E73207468697320646F63756D656E742E0D0A0D0A312E392E20934C696365';
wwv_flow_api.g_varchar2_table(25) := '6E7361626C65940D0A0D0A20202020206D65616E7320686176696E672074686520726967687420746F206772616E742C20746F20746865206D6178696D756D20657874656E7420706F737369626C652C2077686574686572206174207468650D0A202020';
wwv_flow_api.g_varchar2_table(26) := '202074696D65206F662074686520696E697469616C206772616E74206F722073756273657175656E746C792C20616E7920616E6420616C6C206F66207468652072696768747320636F6E76657965642062790D0A202020202074686973204C6963656E73';
wwv_flow_api.g_varchar2_table(27) := '652E0D0A0D0A312E31302E20934D6F64696669636174696F6E73940D0A0D0A20202020206D65616E7320616E79206F662074686520666F6C6C6F77696E673A0D0A0D0A2020202020612E20616E792066696C6520696E20536F7572636520436F64652046';
wwv_flow_api.g_varchar2_table(28) := '6F726D207468617420726573756C74732066726F6D20616E206164646974696F6E20746F2C2064656C6574696F6E0D0A202020202020202066726F6D2C206F72206D6F64696669636174696F6E206F662074686520636F6E74656E7473206F6620436F76';
wwv_flow_api.g_varchar2_table(29) := '6572656420536F6674776172653B206F720D0A0D0A2020202020622E20616E79206E65772066696C6520696E20536F7572636520436F646520466F726D207468617420636F6E7461696E7320616E7920436F766572656420536F6674776172652E0D0A0D';
wwv_flow_api.g_varchar2_table(30) := '0A312E31312E2093506174656E7420436C61696D7394206F66206120436F6E7472696275746F720D0A0D0A2020202020206D65616E7320616E7920706174656E7420636C61696D2873292C20696E636C7564696E6720776974686F7574206C696D697461';
wwv_flow_api.g_varchar2_table(31) := '74696F6E2C206D6574686F642C2070726F636573732C0D0A202020202020616E642061707061726174757320636C61696D732C20696E20616E7920706174656E74204C6963656E7361626C65206279207375636820436F6E7472696275746F7220746861';
wwv_flow_api.g_varchar2_table(32) := '740D0A202020202020776F756C6420626520696E6672696E6765642C2062757420666F7220746865206772616E74206F6620746865204C6963656E73652C20627920746865206D616B696E672C0D0A2020202020207573696E672C2073656C6C696E672C';
wwv_flow_api.g_varchar2_table(33) := '206F66666572696E6720666F722073616C652C20686176696E67206D6164652C20696D706F72742C206F72207472616E73666572206F660D0A2020202020206569746865722069747320436F6E747269627574696F6E73206F722069747320436F6E7472';
wwv_flow_api.g_varchar2_table(34) := '696275746F722056657273696F6E2E0D0A0D0A312E31322E20935365636F6E64617279204C6963656E7365940D0A0D0A2020202020206D65616E73206569746865722074686520474E552047656E6572616C205075626C6963204C6963656E73652C2056';
wwv_flow_api.g_varchar2_table(35) := '657273696F6E20322E302C2074686520474E55204C65737365720D0A20202020202047656E6572616C205075626C6963204C6963656E73652C2056657273696F6E20322E312C2074686520474E552041666665726F2047656E6572616C205075626C6963';
wwv_flow_api.g_varchar2_table(36) := '0D0A2020202020204C6963656E73652C2056657273696F6E20332E302C206F7220616E79206C617465722076657273696F6E73206F662074686F7365206C6963656E7365732E0D0A0D0A312E31332E2093536F7572636520436F646520466F726D940D0A';
wwv_flow_api.g_varchar2_table(37) := '0D0A2020202020206D65616E732074686520666F726D206F662074686520776F726B2070726566657272656420666F72206D616B696E67206D6F64696669636174696F6E732E0D0A0D0A312E31342E2093596F759420286F722093596F757294290D0A0D';
wwv_flow_api.g_varchar2_table(38) := '0A2020202020206D65616E7320616E20696E646976696475616C206F722061206C6567616C20656E746974792065786572636973696E672072696768747320756E64657220746869730D0A2020202020204C6963656E73652E20466F72206C6567616C20';
wwv_flow_api.g_varchar2_table(39) := '656E7469746965732C2093596F759420696E636C7564657320616E7920656E74697479207468617420636F6E74726F6C732C2069730D0A202020202020636F6E74726F6C6C65642062792C206F7220697320756E64657220636F6D6D6F6E20636F6E7472';
wwv_flow_api.g_varchar2_table(40) := '6F6C207769746820596F752E20466F7220707572706F736573206F6620746869730D0A202020202020646566696E6974696F6E2C2093636F6E74726F6C94206D65616E73202861292074686520706F7765722C20646972656374206F7220696E64697265';
wwv_flow_api.g_varchar2_table(41) := '63742C20746F2063617573650D0A20202020202074686520646972656374696F6E206F72206D616E6167656D656E74206F66207375636820656E746974792C207768657468657220627920636F6E7472616374206F720D0A2020202020206F7468657277';
wwv_flow_api.g_varchar2_table(42) := '6973652C206F7220286229206F776E657273686970206F66206D6F7265207468616E2066696674792070657263656E74202835302529206F66207468650D0A2020202020206F75747374616E64696E6720736861726573206F722062656E656669636961';
wwv_flow_api.g_varchar2_table(43) := '6C206F776E657273686970206F66207375636820656E746974792E0D0A0D0A0D0A322E204C6963656E7365204772616E747320616E6420436F6E646974696F6E730D0A0D0A322E312E204772616E74730D0A0D0A20202020204561636820436F6E747269';
wwv_flow_api.g_varchar2_table(44) := '6275746F7220686572656279206772616E747320596F75206120776F726C642D776964652C20726F79616C74792D667265652C0D0A20202020206E6F6E2D6578636C7573697665206C6963656E73653A0D0A0D0A2020202020612E20756E64657220696E';
wwv_flow_api.g_varchar2_table(45) := '74656C6C65637475616C2070726F70657274792072696768747320286F74686572207468616E20706174656E74206F722074726164656D61726B290D0A20202020202020204C6963656E7361626C65206279207375636820436F6E7472696275746F7220';
wwv_flow_api.g_varchar2_table(46) := '746F207573652C20726570726F647563652C206D616B6520617661696C61626C652C0D0A20202020202020206D6F646966792C20646973706C61792C20706572666F726D2C20646973747269627574652C20616E64206F7468657277697365206578706C';
wwv_flow_api.g_varchar2_table(47) := '6F6974206974730D0A2020202020202020436F6E747269627574696F6E732C20656974686572206F6E20616E20756E6D6F6469666965642062617369732C2077697468204D6F64696669636174696F6E732C206F722061730D0A20202020202020207061';
wwv_flow_api.g_varchar2_table(48) := '7274206F662061204C617267657220576F726B3B20616E640D0A0D0A2020202020622E20756E64657220506174656E7420436C61696D73206F66207375636820436F6E7472696275746F7220746F206D616B652C207573652C2073656C6C2C206F666665';
wwv_flow_api.g_varchar2_table(49) := '7220666F720D0A202020202020202073616C652C2068617665206D6164652C20696D706F72742C20616E64206F7468657277697365207472616E73666572206569746865722069747320436F6E747269627574696F6E730D0A20202020202020206F7220';
wwv_flow_api.g_varchar2_table(50) := '69747320436F6E7472696275746F722056657273696F6E2E0D0A0D0A322E322E2045666665637469766520446174650D0A0D0A2020202020546865206C6963656E736573206772616E74656420696E2053656374696F6E20322E31207769746820726573';
wwv_flow_api.g_varchar2_table(51) := '7065637420746F20616E7920436F6E747269627574696F6E206265636F6D650D0A202020202065666665637469766520666F72206561636820436F6E747269627574696F6E206F6E2074686520646174652074686520436F6E7472696275746F72206669';
wwv_flow_api.g_varchar2_table(52) := '7273742064697374726962757465730D0A20202020207375636820436F6E747269627574696F6E2E0D0A0D0A322E332E204C696D69746174696F6E73206F6E204772616E742053636F70650D0A0D0A2020202020546865206C6963656E73657320677261';
wwv_flow_api.g_varchar2_table(53) := '6E74656420696E20746869732053656374696F6E20322061726520746865206F6E6C7920726967687473206772616E74656420756E64657220746869730D0A20202020204C6963656E73652E204E6F206164646974696F6E616C20726967687473206F72';
wwv_flow_api.g_varchar2_table(54) := '206C6963656E7365732077696C6C20626520696D706C6965642066726F6D2074686520646973747269627574696F6E0D0A20202020206F72206C6963656E73696E67206F6620436F766572656420536F66747761726520756E6465722074686973204C69';
wwv_flow_api.g_varchar2_table(55) := '63656E73652E204E6F74776974687374616E64696E672053656374696F6E0D0A2020202020322E312862292061626F76652C206E6F20706174656E74206C6963656E7365206973206772616E746564206279206120436F6E7472696275746F723A0D0A0D';
wwv_flow_api.g_varchar2_table(56) := '0A2020202020612E20666F7220616E7920636F64652074686174206120436F6E7472696275746F72206861732072656D6F7665642066726F6D20436F766572656420536F6674776172653B206F720D0A0D0A2020202020622E20666F7220696E6672696E';
wwv_flow_api.g_varchar2_table(57) := '67656D656E7473206361757365642062793A2028692920596F757220616E6420616E79206F7468657220746869726420706172747992730D0A20202020202020206D6F64696669636174696F6E73206F6620436F766572656420536F6674776172652C20';
wwv_flow_api.g_varchar2_table(58) := '6F7220286969292074686520636F6D62696E6174696F6E206F66206974730D0A2020202020202020436F6E747269627574696F6E732077697468206F7468657220736F66747761726520286578636570742061732070617274206F662069747320436F6E';
wwv_flow_api.g_varchar2_table(59) := '7472696275746F720D0A202020202020202056657273696F6E293B206F720D0A0D0A2020202020632E20756E64657220506174656E7420436C61696D7320696E6672696E67656420627920436F766572656420536F66747761726520696E207468652061';
wwv_flow_api.g_varchar2_table(60) := '6273656E6365206F66206974730D0A2020202020202020436F6E747269627574696F6E732E0D0A0D0A202020202054686973204C6963656E736520646F6573206E6F74206772616E7420616E792072696768747320696E207468652074726164656D6172';
wwv_flow_api.g_varchar2_table(61) := '6B732C2073657276696365206D61726B732C206F720D0A20202020206C6F676F73206F6620616E7920436F6E7472696275746F722028657863657074206173206D6179206265206E656365737361727920746F20636F6D706C792077697468207468650D';
wwv_flow_api.g_varchar2_table(62) := '0A20202020206E6F7469636520726571756972656D656E747320696E2053656374696F6E20332E34292E0D0A0D0A322E342E2053756273657175656E74204C6963656E7365730D0A0D0A20202020204E6F20436F6E7472696275746F72206D616B657320';
wwv_flow_api.g_varchar2_table(63) := '6164646974696F6E616C206772616E7473206173206120726573756C74206F6620596F75722063686F69636520746F0D0A2020202020646973747269627574652074686520436F766572656420536F66747761726520756E646572206120737562736571';
wwv_flow_api.g_varchar2_table(64) := '75656E742076657273696F6E206F662074686973204C6963656E73650D0A2020202020287365652053656374696F6E2031302E3229206F7220756E64657220746865207465726D73206F662061205365636F6E64617279204C6963656E73652028696620';
wwv_flow_api.g_varchar2_table(65) := '7065726D69747465640D0A2020202020756E64657220746865207465726D73206F662053656374696F6E20332E33292E0D0A0D0A322E352E20526570726573656E746174696F6E0D0A0D0A20202020204561636820436F6E7472696275746F7220726570';
wwv_flow_api.g_varchar2_table(66) := '726573656E747320746861742074686520436F6E7472696275746F722062656C69657665732069747320436F6E747269627574696F6E730D0A202020202061726520697473206F726967696E616C206372656174696F6E287329206F7220697420686173';
wwv_flow_api.g_varchar2_table(67) := '2073756666696369656E742072696768747320746F206772616E74207468650D0A202020202072696768747320746F2069747320436F6E747269627574696F6E7320636F6E76657965642062792074686973204C6963656E73652E0D0A0D0A322E362E20';
wwv_flow_api.g_varchar2_table(68) := '46616972205573650D0A0D0A202020202054686973204C6963656E7365206973206E6F7420696E74656E64656420746F206C696D697420616E792072696768747320596F75206861766520756E646572206170706C696361626C650D0A2020202020636F';
wwv_flow_api.g_varchar2_table(69) := '7079726967687420646F637472696E6573206F662066616972207573652C2066616972206465616C696E672C206F72206F74686572206571756976616C656E74732E0D0A0D0A322E372E20436F6E646974696F6E730D0A0D0A202020202053656374696F';
wwv_flow_api.g_varchar2_table(70) := '6E7320332E312C20332E322C20332E332C20616E6420332E342061726520636F6E646974696F6E73206F6620746865206C6963656E736573206772616E74656420696E0D0A202020202053656374696F6E20322E312E0D0A0D0A0D0A332E20526573706F';
wwv_flow_api.g_varchar2_table(71) := '6E736962696C69746965730D0A0D0A332E312E20446973747269627574696F6E206F6620536F7572636520466F726D0D0A0D0A2020202020416C6C20646973747269627574696F6E206F6620436F766572656420536F66747761726520696E20536F7572';
wwv_flow_api.g_varchar2_table(72) := '636520436F646520466F726D2C20696E636C7564696E6720616E790D0A20202020204D6F64696669636174696F6E73207468617420596F7520637265617465206F7220746F20776869636820596F7520636F6E747269627574652C206D75737420626520';
wwv_flow_api.g_varchar2_table(73) := '756E646572207468650D0A20202020207465726D73206F662074686973204C6963656E73652E20596F75206D75737420696E666F726D20726563697069656E747320746861742074686520536F7572636520436F646520466F726D0D0A20202020206F66';
wwv_flow_api.g_varchar2_table(74) := '2074686520436F766572656420536F66747761726520697320676F7665726E656420627920746865207465726D73206F662074686973204C6963656E73652C20616E6420686F770D0A2020202020746865792063616E206F627461696E206120636F7079';
wwv_flow_api.g_varchar2_table(75) := '206F662074686973204C6963656E73652E20596F75206D6179206E6F7420617474656D707420746F20616C746572206F720D0A202020202072657374726963742074686520726563697069656E7473922072696768747320696E2074686520536F757263';
wwv_flow_api.g_varchar2_table(76) := '6520436F646520466F726D2E0D0A0D0A332E322E20446973747269627574696F6E206F662045786563757461626C6520466F726D0D0A0D0A2020202020496620596F75206469737472696275746520436F766572656420536F66747761726520696E2045';
wwv_flow_api.g_varchar2_table(77) := '786563757461626C6520466F726D207468656E3A0D0A0D0A2020202020612E207375636820436F766572656420536F667477617265206D75737420616C736F206265206D61646520617661696C61626C6520696E20536F7572636520436F646520466F72';
wwv_flow_api.g_varchar2_table(78) := '6D2C0D0A202020202020202061732064657363726962656420696E2053656374696F6E20332E312C20616E6420596F75206D75737420696E666F726D20726563697069656E7473206F66207468650D0A202020202020202045786563757461626C652046';
wwv_flow_api.g_varchar2_table(79) := '6F726D20686F7720746865792063616E206F627461696E206120636F7079206F66207375636820536F7572636520436F646520466F726D2062790D0A2020202020202020726561736F6E61626C65206D65616E7320696E20612074696D656C79206D616E';
wwv_flow_api.g_varchar2_table(80) := '6E65722C206174206120636861726765206E6F206D6F7265207468616E2074686520636F73740D0A20202020202020206F6620646973747269627574696F6E20746F2074686520726563697069656E743B20616E640D0A0D0A2020202020622E20596F75';
wwv_flow_api.g_varchar2_table(81) := '206D6179206469737472696275746520737563682045786563757461626C6520466F726D20756E64657220746865207465726D73206F662074686973204C6963656E73652C0D0A20202020202020206F72207375626C6963656E736520697420756E6465';
wwv_flow_api.g_varchar2_table(82) := '7220646966666572656E74207465726D732C2070726F7669646564207468617420746865206C6963656E736520666F720D0A20202020202020207468652045786563757461626C6520466F726D20646F6573206E6F7420617474656D707420746F206C69';
wwv_flow_api.g_varchar2_table(83) := '6D6974206F7220616C7465722074686520726563697069656E7473920D0A202020202020202072696768747320696E2074686520536F7572636520436F646520466F726D20756E6465722074686973204C6963656E73652E0D0A0D0A332E332E20446973';
wwv_flow_api.g_varchar2_table(84) := '747269627574696F6E206F662061204C617267657220576F726B0D0A0D0A2020202020596F75206D61792063726561746520616E6420646973747269627574652061204C617267657220576F726B20756E646572207465726D73206F6620596F75722063';
wwv_flow_api.g_varchar2_table(85) := '686F6963652C0D0A202020202070726F7669646564207468617420596F7520616C736F20636F6D706C7920776974682074686520726571756972656D656E7473206F662074686973204C6963656E736520666F72207468650D0A2020202020436F766572';
wwv_flow_api.g_varchar2_table(86) := '656420536F6674776172652E20496620746865204C617267657220576F726B206973206120636F6D62696E6174696F6E206F6620436F766572656420536F6674776172650D0A202020202077697468206120776F726B20676F7665726E6564206279206F';
wwv_flow_api.g_varchar2_table(87) := '6E65206F72206D6F7265205365636F6E64617279204C6963656E7365732C20616E642074686520436F76657265640D0A2020202020536F667477617265206973206E6F7420496E636F6D70617469626C652057697468205365636F6E64617279204C6963';
wwv_flow_api.g_varchar2_table(88) := '656E7365732C2074686973204C6963656E7365207065726D6974730D0A2020202020596F7520746F206164646974696F6E616C6C792064697374726962757465207375636820436F766572656420536F66747761726520756E6465722074686520746572';
wwv_flow_api.g_varchar2_table(89) := '6D73206F660D0A202020202073756368205365636F6E64617279204C6963656E73652873292C20736F20746861742074686520726563697069656E74206F6620746865204C617267657220576F726B206D61792C2061740D0A2020202020746865697220';
wwv_flow_api.g_varchar2_table(90) := '6F7074696F6E2C206675727468657220646973747269627574652074686520436F766572656420536F66747761726520756E64657220746865207465726D73206F660D0A20202020206569746865722074686973204C6963656E7365206F722073756368';
wwv_flow_api.g_varchar2_table(91) := '205365636F6E64617279204C6963656E73652873292E0D0A0D0A332E342E204E6F74696365730D0A0D0A2020202020596F75206D6179206E6F742072656D6F7665206F7220616C74657220746865207375627374616E6365206F6620616E79206C696365';
wwv_flow_api.g_varchar2_table(92) := '6E7365206E6F74696365732028696E636C7564696E670D0A2020202020636F70797269676874206E6F74696365732C20706174656E74206E6F74696365732C20646973636C61696D657273206F662077617272616E74792C206F72206C696D6974617469';
wwv_flow_api.g_varchar2_table(93) := '6F6E730D0A20202020206F66206C696162696C6974792920636F6E7461696E65642077697468696E2074686520536F7572636520436F646520466F726D206F662074686520436F76657265640D0A2020202020536F6674776172652C2065786365707420';
wwv_flow_api.g_varchar2_table(94) := '7468617420596F75206D617920616C74657220616E79206C6963656E7365206E6F746963657320746F2074686520657874656E740D0A2020202020726571756972656420746F2072656D656479206B6E6F776E206661637475616C20696E616363757261';
wwv_flow_api.g_varchar2_table(95) := '636965732E0D0A0D0A332E352E204170706C69636174696F6E206F66204164646974696F6E616C205465726D730D0A0D0A2020202020596F75206D61792063686F6F736520746F206F666665722C20616E6420746F206368617267652061206665652066';
wwv_flow_api.g_varchar2_table(96) := '6F722C2077617272616E74792C20737570706F72742C0D0A2020202020696E64656D6E697479206F72206C696162696C697479206F626C69676174696F6E7320746F206F6E65206F72206D6F726520726563697069656E7473206F6620436F7665726564';
wwv_flow_api.g_varchar2_table(97) := '0D0A2020202020536F6674776172652E20486F77657665722C20596F75206D617920646F20736F206F6E6C79206F6E20596F7572206F776E20626568616C662C20616E64206E6F74206F6E20626568616C660D0A20202020206F6620616E7920436F6E74';
wwv_flow_api.g_varchar2_table(98) := '72696275746F722E20596F75206D757374206D616B65206974206162736F6C7574656C7920636C656172207468617420616E7920737563680D0A202020202077617272616E74792C20737570706F72742C20696E64656D6E6974792C206F72206C696162';
wwv_flow_api.g_varchar2_table(99) := '696C697479206F626C69676174696F6E206973206F66666572656420627920596F750D0A2020202020616C6F6E652C20616E6420596F752068657265627920616772656520746F20696E64656D6E69667920657665727920436F6E7472696275746F7220';
wwv_flow_api.g_varchar2_table(100) := '666F7220616E790D0A20202020206C696162696C69747920696E637572726564206279207375636820436F6E7472696275746F72206173206120726573756C74206F662077617272616E74792C20737570706F72742C0D0A2020202020696E64656D6E69';
wwv_flow_api.g_varchar2_table(101) := '7479206F72206C696162696C697479207465726D7320596F75206F666665722E20596F75206D617920696E636C756465206164646974696F6E616C0D0A2020202020646973636C61696D657273206F662077617272616E747920616E64206C696D697461';
wwv_flow_api.g_varchar2_table(102) := '74696F6E73206F66206C696162696C69747920737065636966696320746F20616E790D0A20202020206A7572697364696374696F6E2E0D0A0D0A342E20496E6162696C69747920746F20436F6D706C792044756520746F2053746174757465206F722052';
wwv_flow_api.g_varchar2_table(103) := '6567756C6174696F6E0D0A0D0A202020496620697420697320696D706F737369626C6520666F7220596F7520746F20636F6D706C79207769746820616E79206F6620746865207465726D73206F662074686973204C6963656E73650D0A20202077697468';
wwv_flow_api.g_varchar2_table(104) := '207265737065637420746F20736F6D65206F7220616C6C206F662074686520436F766572656420536F6674776172652064756520746F20737461747574652C206A7564696369616C0D0A2020206F726465722C206F7220726567756C6174696F6E207468';
wwv_flow_api.g_varchar2_table(105) := '656E20596F75206D7573743A2028612920636F6D706C79207769746820746865207465726D73206F662074686973204C6963656E73650D0A202020746F20746865206D6178696D756D20657874656E7420706F737369626C653B20616E64202862292064';
wwv_flow_api.g_varchar2_table(106) := '6573637269626520746865206C696D69746174696F6E7320616E642074686520636F64650D0A20202074686579206166666563742E2053756368206465736372697074696F6E206D75737420626520706C6163656420696E206120746578742066696C65';
wwv_flow_api.g_varchar2_table(107) := '20696E636C75646564207769746820616C6C0D0A202020646973747269627574696F6E73206F662074686520436F766572656420536F66747761726520756E6465722074686973204C6963656E73652E2045786365707420746F207468650D0A20202065';
wwv_flow_api.g_varchar2_table(108) := '7874656E742070726F686962697465642062792073746174757465206F7220726567756C6174696F6E2C2073756368206465736372697074696F6E206D7573742062650D0A20202073756666696369656E746C792064657461696C656420666F72206120';
wwv_flow_api.g_varchar2_table(109) := '726563697069656E74206F66206F7264696E61727920736B696C6C20746F2062652061626C6520746F0D0A202020756E6465727374616E642069742E0D0A0D0A352E205465726D696E6174696F6E0D0A0D0A352E312E2054686520726967687473206772';
wwv_flow_api.g_varchar2_table(110) := '616E74656420756E6465722074686973204C6963656E73652077696C6C207465726D696E617465206175746F6D61746963616C6C7920696620596F750D0A20202020206661696C20746F20636F6D706C79207769746820616E79206F6620697473207465';
wwv_flow_api.g_varchar2_table(111) := '726D732E20486F77657665722C20696620596F75206265636F6D6520636F6D706C69616E742C0D0A20202020207468656E2074686520726967687473206772616E74656420756E6465722074686973204C6963656E73652066726F6D2061207061727469';
wwv_flow_api.g_varchar2_table(112) := '63756C617220436F6E7472696275746F720D0A2020202020617265207265696E737461746564202861292070726F766973696F6E616C6C792C20756E6C65737320616E6420756E74696C207375636820436F6E7472696275746F720D0A20202020206578';
wwv_flow_api.g_varchar2_table(113) := '706C696369746C7920616E642066696E616C6C79207465726D696E6174657320596F7572206772616E74732C20616E6420286229206F6E20616E206F6E676F696E672062617369732C0D0A20202020206966207375636820436F6E7472696275746F7220';
wwv_flow_api.g_varchar2_table(114) := '6661696C7320746F206E6F7469667920596F75206F6620746865206E6F6E2D636F6D706C69616E636520627920736F6D650D0A2020202020726561736F6E61626C65206D65616E73207072696F7220746F203630206461797320616674657220596F7520';
wwv_flow_api.g_varchar2_table(115) := '6861766520636F6D65206261636B20696E746F20636F6D706C69616E63652E0D0A20202020204D6F72656F7665722C20596F7572206772616E74732066726F6D206120706172746963756C617220436F6E7472696275746F7220617265207265696E7374';
wwv_flow_api.g_varchar2_table(116) := '61746564206F6E20616E0D0A20202020206F6E676F696E67206261736973206966207375636820436F6E7472696275746F72206E6F74696669657320596F75206F6620746865206E6F6E2D636F6D706C69616E63652062790D0A2020202020736F6D6520';
wwv_flow_api.g_varchar2_table(117) := '726561736F6E61626C65206D65616E732C2074686973206973207468652066697273742074696D6520596F752068617665207265636569766564206E6F74696365206F660D0A20202020206E6F6E2D636F6D706C69616E63652077697468207468697320';
wwv_flow_api.g_varchar2_table(118) := '4C6963656E73652066726F6D207375636820436F6E7472696275746F722C20616E6420596F75206265636F6D650D0A2020202020636F6D706C69616E74207072696F7220746F203330206461797320616674657220596F75722072656365697074206F66';
wwv_flow_api.g_varchar2_table(119) := '20746865206E6F746963652E0D0A0D0A352E322E20496620596F7520696E697469617465206C697469676174696F6E20616761696E737420616E7920656E7469747920627920617373657274696E67206120706174656E740D0A2020202020696E667269';
wwv_flow_api.g_varchar2_table(120) := '6E67656D656E7420636C61696D20286578636C7564696E67206465636C617261746F7279206A7564676D656E7420616374696F6E732C20636F756E7465722D636C61696D732C0D0A2020202020616E642063726F73732D636C61696D732920616C6C6567';
wwv_flow_api.g_varchar2_table(121) := '696E672074686174206120436F6E7472696275746F722056657273696F6E206469726563746C79206F720D0A2020202020696E6469726563746C7920696E6672696E67657320616E7920706174656E742C207468656E2074686520726967687473206772';
wwv_flow_api.g_varchar2_table(122) := '616E74656420746F20596F7520627920616E7920616E640D0A2020202020616C6C20436F6E7472696275746F727320666F722074686520436F766572656420536F66747761726520756E6465722053656374696F6E20322E31206F662074686973204C69';
wwv_flow_api.g_varchar2_table(123) := '63656E73650D0A20202020207368616C6C207465726D696E6174652E0D0A0D0A352E332E20496E20746865206576656E74206F66207465726D696E6174696F6E20756E6465722053656374696F6E7320352E31206F7220352E322061626F76652C20616C';
wwv_flow_api.g_varchar2_table(124) := '6C20656E6420757365720D0A20202020206C6963656E73652061677265656D656E747320286578636C7564696E67206469737472696275746F727320616E6420726573656C6C657273292077686963682068617665206265656E0D0A202020202076616C';
wwv_flow_api.g_varchar2_table(125) := '69646C79206772616E74656420627920596F75206F7220596F7572206469737472696275746F727320756E6465722074686973204C6963656E7365207072696F7220746F0D0A20202020207465726D696E6174696F6E207368616C6C2073757276697665';
wwv_flow_api.g_varchar2_table(126) := '207465726D696E6174696F6E2E0D0A0D0A362E20446973636C61696D6572206F662057617272616E74790D0A0D0A202020436F766572656420536F6674776172652069732070726F766964656420756E6465722074686973204C6963656E7365206F6E20';
wwv_flow_api.g_varchar2_table(127) := '616E20936173206973942062617369732C20776974686F75740D0A20202077617272616E7479206F6620616E79206B696E642C20656974686572206578707265737365642C20696D706C6965642C206F72207374617475746F72792C20696E636C756469';
wwv_flow_api.g_varchar2_table(128) := '6E672C0D0A202020776974686F7574206C696D69746174696F6E2C2077617272616E7469657320746861742074686520436F766572656420536F6674776172652069732066726565206F6620646566656374732C0D0A2020206D65726368616E7461626C';
wwv_flow_api.g_varchar2_table(129) := '652C2066697420666F72206120706172746963756C617220707572706F7365206F72206E6F6E2D696E6672696E67696E672E2054686520656E746972650D0A2020207269736B20617320746F20746865207175616C69747920616E6420706572666F726D';
wwv_flow_api.g_varchar2_table(130) := '616E6365206F662074686520436F766572656420536F667477617265206973207769746820596F752E0D0A20202053686F756C6420616E7920436F766572656420536F6674776172652070726F76652064656665637469766520696E20616E7920726573';
wwv_flow_api.g_varchar2_table(131) := '706563742C20596F7520286E6F7420616E790D0A202020436F6E7472696275746F722920617373756D652074686520636F7374206F6620616E79206E656365737361727920736572766963696E672C207265706169722C206F720D0A202020636F727265';
wwv_flow_api.g_varchar2_table(132) := '6374696F6E2E205468697320646973636C61696D6572206F662077617272616E747920636F6E737469747574657320616E20657373656E7469616C2070617274206F6620746869730D0A2020204C6963656E73652E204E6F20757365206F662020616E79';
wwv_flow_api.g_varchar2_table(133) := '20436F766572656420536F66747761726520697320617574686F72697A656420756E6465722074686973204C6963656E73650D0A20202065786365707420756E646572207468697320646973636C61696D65722E0D0A0D0A372E204C696D69746174696F';
wwv_flow_api.g_varchar2_table(134) := '6E206F66204C696162696C6974790D0A0D0A202020556E646572206E6F2063697263756D7374616E63657320616E6420756E646572206E6F206C6567616C207468656F72792C207768657468657220746F72742028696E636C7564696E670D0A2020206E';
wwv_flow_api.g_varchar2_table(135) := '65676C6967656E6365292C20636F6E74726163742C206F72206F74686572776973652C207368616C6C20616E7920436F6E7472696275746F722C206F7220616E796F6E652077686F0D0A202020646973747269627574657320436F766572656420536F66';
wwv_flow_api.g_varchar2_table(136) := '7477617265206173207065726D69747465642061626F76652C206265206C6961626C6520746F20596F7520666F7220616E790D0A2020206469726563742C20696E6469726563742C207370656369616C2C20696E636964656E74616C2C206F7220636F6E';
wwv_flow_api.g_varchar2_table(137) := '73657175656E7469616C2064616D61676573206F6620616E790D0A20202063686172616374657220696E636C7564696E672C20776974686F7574206C696D69746174696F6E2C2064616D6167657320666F72206C6F73742070726F666974732C206C6F73';
wwv_flow_api.g_varchar2_table(138) := '73206F660D0A202020676F6F6477696C6C2C20776F726B2073746F70706167652C20636F6D7075746572206661696C757265206F72206D616C66756E6374696F6E2C206F7220616E7920616E6420616C6C0D0A2020206F7468657220636F6D6D65726369';
wwv_flow_api.g_varchar2_table(139) := '616C2064616D61676573206F72206C6F737365732C206576656E2069662073756368207061727479207368616C6C2068617665206265656E0D0A202020696E666F726D6564206F662074686520706F73736962696C697479206F6620737563682064616D';
wwv_flow_api.g_varchar2_table(140) := '616765732E2054686973206C696D69746174696F6E206F66206C696162696C6974790D0A2020207368616C6C206E6F74206170706C7920746F206C696162696C69747920666F72206465617468206F7220706572736F6E616C20696E6A75727920726573';
wwv_flow_api.g_varchar2_table(141) := '756C74696E672066726F6D20737563680D0A20202070617274799273206E65676C6967656E636520746F2074686520657874656E74206170706C696361626C65206C61772070726F6869626974732073756368206C696D69746174696F6E2E0D0A202020';
wwv_flow_api.g_varchar2_table(142) := '536F6D65206A7572697364696374696F6E7320646F206E6F7420616C6C6F7720746865206578636C7573696F6E206F72206C696D69746174696F6E206F6620696E636964656E74616C206F720D0A202020636F6E73657175656E7469616C2064616D6167';
wwv_flow_api.g_varchar2_table(143) := '65732C20736F2074686973206578636C7573696F6E20616E64206C696D69746174696F6E206D6179206E6F74206170706C7920746F20596F752E0D0A0D0A382E204C697469676174696F6E0D0A0D0A202020416E79206C697469676174696F6E2072656C';
wwv_flow_api.g_varchar2_table(144) := '6174696E6720746F2074686973204C6963656E7365206D61792062652062726F75676874206F6E6C7920696E2074686520636F75727473206F660D0A20202061206A7572697364696374696F6E2077686572652074686520646566656E64616E74206D61';
wwv_flow_api.g_varchar2_table(145) := '696E7461696E7320697473207072696E636970616C20706C616365206F6620627573696E6573730D0A202020616E642073756368206C697469676174696F6E207368616C6C20626520676F7665726E6564206279206C617773206F662074686174206A75';
wwv_flow_api.g_varchar2_table(146) := '72697364696374696F6E2C20776974686F75740D0A2020207265666572656E636520746F2069747320636F6E666C6963742D6F662D6C61772070726F766973696F6E732E204E6F7468696E6720696E20746869732053656374696F6E207368616C6C0D0A';
wwv_flow_api.g_varchar2_table(147) := '20202070726576656E7420612070617274799273206162696C69747920746F206272696E672063726F73732D636C61696D73206F7220636F756E7465722D636C61696D732E0D0A0D0A392E204D697363656C6C616E656F75730D0A0D0A20202054686973';
wwv_flow_api.g_varchar2_table(148) := '204C6963656E736520726570726573656E74732074686520636F6D706C6574652061677265656D656E7420636F6E6365726E696E6720746865207375626A656374206D61747465720D0A202020686572656F662E20496620616E792070726F766973696F';
wwv_flow_api.g_varchar2_table(149) := '6E206F662074686973204C6963656E73652069732068656C6420746F20626520756E656E666F72636561626C652C20737563680D0A20202070726F766973696F6E207368616C6C206265207265666F726D6564206F6E6C7920746F207468652065787465';
wwv_flow_api.g_varchar2_table(150) := '6E74206E656365737361727920746F206D616B652069740D0A202020656E666F72636561626C652E20416E79206C6177206F7220726567756C6174696F6E2077686963682070726F7669646573207468617420746865206C616E6775616765206F662061';
wwv_flow_api.g_varchar2_table(151) := '0D0A202020636F6E7472616374207368616C6C20626520636F6E73747275656420616761696E7374207468652064726166746572207368616C6C206E6F74206265207573656420746F20636F6E73747275650D0A20202074686973204C6963656E736520';
wwv_flow_api.g_varchar2_table(152) := '616761696E7374206120436F6E7472696275746F722E0D0A0D0A0D0A31302E2056657273696F6E73206F6620746865204C6963656E73650D0A0D0A31302E312E204E65772056657273696F6E730D0A0D0A2020202020204D6F7A696C6C6120466F756E64';
wwv_flow_api.g_varchar2_table(153) := '6174696F6E20697320746865206C6963656E736520737465776172642E204578636570742061732070726F766964656420696E2053656374696F6E0D0A20202020202031302E332C206E6F206F6E65206F74686572207468616E20746865206C6963656E';
wwv_flow_api.g_varchar2_table(154) := '73652073746577617264206861732074686520726967687420746F206D6F64696679206F720D0A2020202020207075626C697368206E65772076657273696F6E73206F662074686973204C6963656E73652E20456163682076657273696F6E2077696C6C';
wwv_flow_api.g_varchar2_table(155) := '20626520676976656E20610D0A20202020202064697374696E6775697368696E672076657273696F6E206E756D6265722E0D0A0D0A31302E322E20456666656374206F66204E65772056657273696F6E730D0A0D0A202020202020596F75206D61792064';
wwv_flow_api.g_varchar2_table(156) := '6973747269627574652074686520436F766572656420536F66747761726520756E64657220746865207465726D73206F66207468652076657273696F6E206F660D0A202020202020746865204C6963656E736520756E64657220776869636820596F7520';
wwv_flow_api.g_varchar2_table(157) := '6F726967696E616C6C792072656365697665642074686520436F766572656420536F6674776172652C206F720D0A202020202020756E64657220746865207465726D73206F6620616E792073756273657175656E742076657273696F6E207075626C6973';
wwv_flow_api.g_varchar2_table(158) := '68656420627920746865206C6963656E73650D0A202020202020737465776172642E0D0A0D0A31302E332E204D6F6469666965642056657273696F6E730D0A0D0A202020202020496620796F752063726561746520736F667477617265206E6F7420676F';
wwv_flow_api.g_varchar2_table(159) := '7665726E65642062792074686973204C6963656E73652C20616E6420796F752077616E7420746F0D0A2020202020206372656174652061206E6577206C6963656E736520666F72207375636820736F6674776172652C20796F75206D6179206372656174';
wwv_flow_api.g_varchar2_table(160) := '6520616E64207573652061206D6F6469666965640D0A20202020202076657273696F6E206F662074686973204C6963656E736520696620796F752072656E616D6520746865206C6963656E736520616E642072656D6F766520616E790D0A202020202020';
wwv_flow_api.g_varchar2_table(161) := '7265666572656E63657320746F20746865206E616D65206F6620746865206C6963656E73652073746577617264202865786365707420746F206E6F7465207468617420737563680D0A2020202020206D6F646966696564206C6963656E73652064696666';
wwv_flow_api.g_varchar2_table(162) := '6572732066726F6D2074686973204C6963656E7365292E0D0A0D0A31302E342E20446973747269627574696E6720536F7572636520436F646520466F726D207468617420697320496E636F6D70617469626C652057697468205365636F6E64617279204C';
wwv_flow_api.g_varchar2_table(163) := '6963656E7365730D0A202020202020496620596F752063686F6F736520746F206469737472696275746520536F7572636520436F646520466F726D207468617420697320496E636F6D70617469626C6520576974680D0A2020202020205365636F6E6461';
wwv_flow_api.g_varchar2_table(164) := '7279204C6963656E73657320756E64657220746865207465726D73206F6620746869732076657273696F6E206F6620746865204C6963656E73652C207468650D0A2020202020206E6F746963652064657363726962656420696E20457868696269742042';
wwv_flow_api.g_varchar2_table(165) := '206F662074686973204C6963656E7365206D7573742062652061747461636865642E0D0A0D0A457868696269742041202D20536F7572636520436F646520466F726D204C6963656E7365204E6F746963650D0A0D0A2020202020205468697320536F7572';
wwv_flow_api.g_varchar2_table(166) := '636520436F646520466F726D206973207375626A65637420746F207468650D0A2020202020207465726D73206F6620746865204D6F7A696C6C61205075626C6963204C6963656E73652C20762E0D0A202020202020322E302E204966206120636F707920';
wwv_flow_api.g_varchar2_table(167) := '6F6620746865204D504C20776173206E6F740D0A2020202020206469737472696275746564207769746820746869732066696C652C20596F752063616E0D0A2020202020206F627461696E206F6E652061740D0A202020202020687474703A2F2F6D6F7A';
wwv_flow_api.g_varchar2_table(168) := '696C6C612E6F72672F4D504C2F322E302F2E0D0A0D0A4966206974206973206E6F7420706F737369626C65206F7220646573697261626C6520746F2070757420746865206E6F7469636520696E206120706172746963756C61722066696C652C20746865';
wwv_flow_api.g_varchar2_table(169) := '6E0D0A596F75206D617920696E636C75646520746865206E6F7469636520696E2061206C6F636174696F6E2028737563682061732061204C4943454E53452066696C6520696E20612072656C6576616E740D0A6469726563746F72792920776865726520';
wwv_flow_api.g_varchar2_table(170) := '6120726563697069656E7420776F756C64206265206C696B656C7920746F206C6F6F6B20666F7220737563682061206E6F746963652E0D0A0D0A596F75206D617920616464206164646974696F6E616C206163637572617465206E6F7469636573206F66';
wwv_flow_api.g_varchar2_table(171) := '20636F70797269676874206F776E6572736869702E0D0A0D0A457868696269742042202D2093496E636F6D70617469626C652057697468205365636F6E64617279204C6963656E73657394204E6F746963650D0A0D0A2020202020205468697320536F75';
wwv_flow_api.g_varchar2_table(172) := '72636520436F646520466F726D2069732093496E636F6D70617469626C650D0A20202020202057697468205365636F6E64617279204C6963656E736573942C20617320646566696E65642062790D0A202020202020746865204D6F7A696C6C6120507562';
wwv_flow_api.g_varchar2_table(173) := '6C6963204C6963656E73652C20762E20322E302E0D0A0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(65252095960890162077)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_file_name=>'LICENSE4LIBS'
,p_mime_type=>'application/octet-stream'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2166756E6374696F6E28652C74297B226F626A656374223D3D747970656F66206578706F727473262622756E646566696E656422213D747970656F66206D6F64756C653F6D6F64756C652E6578706F7274733D7428293A2266756E6374696F6E223D3D74';
wwv_flow_api.g_varchar2_table(2) := '7970656F6620646566696E652626646566696E652E616D643F646566696E652874293A652E444F4D5075726966793D7428297D28746869732C66756E6374696F6E28297B2275736520737472696374223B66756E6374696F6E206528652C74297B682626';
wwv_flow_api.g_varchar2_table(3) := '6828652C6E756C6C293B666F722876617220723D742E6C656E6774683B722D2D3B297B766172206E3D745B725D3B69662822737472696E67223D3D747970656F66206E297B766172206F3D6E2E746F4C6F7765724361736528293B6F213D3D6E2626284F';
wwv_flow_api.g_varchar2_table(4) := '626A6563742E697346726F7A656E2874297C7C28745B725D3D6F292C6E3D6F297D655B6E5D3D21307D72657475726E20657D66756E6374696F6E20742865297B76617220743D7B7D2C723D766F696420303B666F72287220696E2065297928672C652C5B';
wwv_flow_api.g_varchar2_table(5) := '725D29262628745B725D3D655B725D293B72657475726E20747D66756E6374696F6E20722865297B69662841727261792E69734172726179286529297B666F722876617220743D302C723D417272617928652E6C656E677468293B743C652E6C656E6774';
wwv_flow_api.g_varchar2_table(6) := '683B742B2B29725B745D3D655B745D3B72657475726E20727D72657475726E2041727261792E66726F6D2865297D66756E6374696F6E206E28297B766172206F3D617267756D656E74732E6C656E6774683E302626766F69642030213D3D617267756D65';
wwv_flow_api.g_varchar2_table(7) := '6E74735B305D3F617267756D656E74735B305D3A5228292C753D66756E6374696F6E2865297B72657475726E206E2865297D3B696628752E76657273696F6E3D22312E302E3130222C752E72656D6F7665643D5B5D2C216F7C7C216F2E646F63756D656E';
wwv_flow_api.g_varchar2_table(8) := '747C7C39213D3D6F2E646F63756D656E742E6E6F6465547970652972657475726E20752E6973537570706F727465643D21312C753B76617220673D6F2E646F63756D656E742C683D21312C793D21312C763D6F2E646F63756D656E742C433D6F2E446F63';
wwv_flow_api.g_varchar2_table(9) := '756D656E74467261676D656E742C6B3D6F2E48544D4C54656D706C617465456C656D656E742C443D6F2E4E6F64652C493D6F2E4E6F646546696C7465722C483D6F2E4E616D65644E6F64654D61702C7A3D766F696420303D3D3D483F6F2E4E616D65644E';
wwv_flow_api.g_varchar2_table(10) := '6F64654D61707C7C6F2E4D6F7A4E616D6564417474724D61703A482C503D6F2E546578742C463D6F2E436F6D6D656E742C6A3D6F2E444F4D5061727365722C553D6F2E5472757374656454797065733B6966282266756E6374696F6E223D3D747970656F';
wwv_flow_api.g_varchar2_table(11) := '66206B297B76617220243D762E637265617465456C656D656E74282274656D706C61746522293B242E636F6E74656E742626242E636F6E74656E742E6F776E6572446F63756D656E74262628763D242E636F6E74656E742E6F776E6572446F63756D656E';
wwv_flow_api.g_varchar2_table(12) := '74297D76617220423D5F28552C67292C563D423F422E63726561746548544D4C282222293A22222C573D762C713D572E696D706C656D656E746174696F6E2C473D572E6372656174654E6F64654974657261746F722C593D572E676574456C656D656E74';
wwv_flow_api.g_varchar2_table(13) := '7342795461674E616D652C583D572E637265617465446F63756D656E74467261676D656E742C4A3D672E696D706F72744E6F64652C4B3D7B7D3B752E6973537570706F727465643D712626766F69642030213D3D712E63726561746548544D4C446F6375';
wwv_flow_api.g_varchar2_table(14) := '6D656E74262639213D3D762E646F63756D656E744D6F64653B76617220513D622C5A3D542C65653D452C74653D4C2C72653D412C6E653D532C6F653D782C69653D6E756C6C2C61653D65287B7D2C5B5D2E636F6E63617428722869292C722861292C7228';
wwv_flow_api.g_varchar2_table(15) := '6C292C722873292C7228632929292C6C653D6E756C6C2C73653D65287B7D2C5B5D2E636F6E63617428722864292C722866292C722870292C72286D2929292C63653D6E756C6C2C75653D6E756C6C2C64653D21302C66653D21302C70653D21312C6D653D';
wwv_flow_api.g_varchar2_table(16) := '21312C67653D21312C68653D21312C79653D21312C76653D21312C62653D21312C54653D21312C45653D21312C4C653D21302C78653D21302C41653D21312C53653D7B7D2C4D653D65287B7D2C5B22617564696F222C2268656164222C226D617468222C';
wwv_flow_api.g_varchar2_table(17) := '22736372697074222C227374796C65222C2274656D706C617465222C22737667222C22766964656F225D292C4F653D65287B7D2C5B22617564696F222C22766964656F222C22696D67222C22736F75726365222C22696D616765225D292C4E653D65287B';
wwv_flow_api.g_varchar2_table(18) := '7D2C5B22616C74222C22636C617373222C22666F72222C226964222C226C6162656C222C226E616D65222C227061747465726E222C22706C616365686F6C646572222C2273756D6D617279222C227469746C65222C2276616C7565222C227374796C6522';
wwv_flow_api.g_varchar2_table(19) := '2C22786D6C6E73225D292C77653D6E756C6C2C52653D762E637265617465456C656D656E742822666F726D22292C5F653D66756E6374696F6E286E297B7765262677653D3D3D6E7C7C286E2626226F626A656374223D3D3D28766F696420303D3D3D6E3F';
wwv_flow_api.g_varchar2_table(20) := '22756E646566696E6564223A4D286E29297C7C286E3D7B7D292C69653D22414C4C4F5745445F5441475322696E206E3F65287B7D2C6E2E414C4C4F5745445F54414753293A61652C6C653D22414C4C4F5745445F4154545222696E206E3F65287B7D2C6E';
wwv_flow_api.g_varchar2_table(21) := '2E414C4C4F5745445F41545452293A73652C63653D22464F524249445F5441475322696E206E3F65287B7D2C6E2E464F524249445F54414753293A7B7D2C75653D22464F524249445F4154545222696E206E3F65287B7D2C6E2E464F524249445F415454';
wwv_flow_api.g_varchar2_table(22) := '52293A7B7D2C53653D225553455F50524F46494C455322696E206E26266E2E5553455F50524F46494C45532C64653D2131213D3D6E2E414C4C4F575F415249415F415454522C66653D2131213D3D6E2E414C4C4F575F444154415F415454522C70653D6E';
wwv_flow_api.g_varchar2_table(23) := '2E414C4C4F575F554E4B4E4F574E5F50524F544F434F4C537C7C21312C6D653D6E2E534146455F464F525F4A51554552597C7C21312C67653D6E2E534146455F464F525F54454D504C415445537C7C21312C68653D6E2E57484F4C455F444F43554D454E';
wwv_flow_api.g_varchar2_table(24) := '547C7C21312C62653D6E2E52455455524E5F444F4D7C7C21312C54653D6E2E52455455524E5F444F4D5F465241474D454E547C7C21312C45653D6E2E52455455524E5F444F4D5F494D504F52547C7C21312C76653D6E2E464F5243455F424F44597C7C21';
wwv_flow_api.g_varchar2_table(25) := '312C4C653D2131213D3D6E2E53414E4954495A455F444F4D2C78653D2131213D3D6E2E4B4545505F434F4E54454E542C41653D6E2E494E5F504C4143457C7C21312C6F653D6E2E414C4C4F5745445F5552495F5245474558507C7C6F652C676526262866';
wwv_flow_api.g_varchar2_table(26) := '653D2131292C546526262862653D2130292C536526262869653D65287B7D2C5B5D2E636F6E636174287228632929292C6C653D5B5D2C21303D3D3D53652E68746D6C262628652869652C69292C65286C652C6429292C21303D3D3D53652E737667262628';
wwv_flow_api.g_varchar2_table(27) := '652869652C61292C65286C652C66292C65286C652C6D29292C21303D3D3D53652E73766746696C74657273262628652869652C6C292C65286C652C66292C65286C652C6D29292C21303D3D3D53652E6D6174684D6C262628652869652C73292C65286C65';
wwv_flow_api.g_varchar2_table(28) := '2C70292C65286C652C6D2929292C6E2E4144445F5441475326262869653D3D3D616526262869653D7428696529292C652869652C6E2E4144445F5441475329292C6E2E4144445F415454522626286C653D3D3D73652626286C653D74286C6529292C6528';
wwv_flow_api.g_varchar2_table(29) := '6C652C6E2E4144445F4154545229292C6E2E4144445F5552495F534146455F41545452262665284E652C6E2E4144445F5552495F534146455F41545452292C786526262869655B222374657874225D3D2130292C68652626652869652C5B2268746D6C22';
wwv_flow_api.g_varchar2_table(30) := '2C2268656164222C22626F6479225D292C69652E7461626C652626652869652C5B2274626F6479225D292C77262677286E292C77653D6E297D2C43653D66756E6374696F6E2865297B752E72656D6F7665642E70757368287B656C656D656E743A657D29';
wwv_flow_api.g_varchar2_table(31) := '3B7472797B652E706172656E744E6F64652E72656D6F76654368696C642865297D63617463682874297B652E6F7574657248544D4C3D567D7D2C6B653D66756E6374696F6E28652C74297B7472797B752E72656D6F7665642E70757368287B6174747269';
wwv_flow_api.g_varchar2_table(32) := '627574653A742E6765744174747269627574654E6F64652865292C66726F6D3A747D297D63617463682865297B752E72656D6F7665642E70757368287B6174747269627574653A6E756C6C2C66726F6D3A747D297D742E72656D6F766541747472696275';
wwv_flow_api.g_varchar2_table(33) := '74652865297D2C44653D66756E6374696F6E2874297B76617220723D766F696420302C6E3D766F696420303B696628766529743D223C72656D6F76653E3C2F72656D6F76653E222B743B656C73657B766172206F3D742E6D61746368282F5E5B5C735D2B';
wwv_flow_api.g_varchar2_table(34) := '2F293B286E3D6F26266F5B305D29262628743D742E736C696365286E2E6C656E67746829297D69662868297472797B723D286E6577206A292E706172736546726F6D537472696E6728742C22746578742F68746D6C22297D63617463682865297B7D6966';
wwv_flow_api.g_varchar2_table(35) := '28792626652863652C5B227469746C65225D292C21727C7C21722E646F63756D656E74456C656D656E74297B76617220693D28723D712E63726561746548544D4C446F63756D656E7428222229292E626F64793B692E706172656E744E6F64652E72656D';
wwv_flow_api.g_varchar2_table(36) := '6F76654368696C6428692E706172656E744E6F64652E6669727374456C656D656E744368696C64292C692E6F7574657248544D4C3D423F422E63726561746548544D4C2874293A747D72657475726E206E2626722E626F64792E696E736572744265666F';
wwv_flow_api.g_varchar2_table(37) := '726528762E637265617465546578744E6F6465286E292C722E626F64792E6368696C644E6F6465735B305D7C7C6E756C6C292C592E63616C6C28722C68653F2268746D6C223A22626F647922295B305D7D3B752E6973537570706F727465642626286675';
wwv_flow_api.g_varchar2_table(38) := '6E6374696F6E28297B7472797B446528273C7376673E3C703E3C7374796C653E3C696D67207372633D223C2F7374796C653E3C696D67207372633D78206F6E6572726F723D312F2F223E27292E717565727953656C6563746F72282273766720696D6722';
wwv_flow_api.g_varchar2_table(39) := '29262628683D2130297D63617463682865297B7D7D28292C66756E6374696F6E28297B7472797B446528223C782F3E3C7469746C653E266C743B2F7469746C652667743B266C743B696D672667743B22292E717565727953656C6563746F722822746974';
wwv_flow_api.g_varchar2_table(40) := '6C6522292E696E6E657248544D4C2E6D61746368282F3C5C2F7469746C652F29262628793D2130297D63617463682865297B7D7D2829293B7661722049653D66756E6374696F6E2865297B72657475726E20472E63616C6C28652E6F776E6572446F6375';
wwv_flow_api.g_varchar2_table(41) := '6D656E747C7C652C652C492E53484F575F454C454D454E547C492E53484F575F434F4D4D454E547C492E53484F575F544558542C66756E6374696F6E28297B72657475726E20492E46494C5445525F4143434550547D2C2131297D2C48653D66756E6374';
wwv_flow_api.g_varchar2_table(42) := '696F6E2865297B72657475726E226F626A656374223D3D3D28766F696420303D3D3D443F22756E646566696E6564223A4D284429293F6520696E7374616E63656F6620443A652626226F626A656374223D3D3D28766F696420303D3D3D653F22756E6465';
wwv_flow_api.g_varchar2_table(43) := '66696E6564223A4D286529292626226E756D626572223D3D747970656F6620652E6E6F646554797065262622737472696E67223D3D747970656F6620652E6E6F64654E616D657D2C7A653D66756E6374696F6E28652C742C72297B4B5B655D26264B5B65';
wwv_flow_api.g_varchar2_table(44) := '5D2E666F72456163682866756E6374696F6E2865297B652E63616C6C28752C742C722C7765297D297D2C50653D66756E6374696F6E2865297B76617220743D766F696420303B6966287A6528226265666F726553616E6974697A65456C656D656E747322';
wwv_flow_api.g_varchar2_table(45) := '2C652C6E756C6C292C66756E6374696F6E2865297B72657475726E21286520696E7374616E63656F6620507C7C6520696E7374616E63656F6620467C7C22737472696E67223D3D747970656F6620652E6E6F64654E616D65262622737472696E67223D3D';
wwv_flow_api.g_varchar2_table(46) := '747970656F6620652E74657874436F6E74656E7426262266756E6374696F6E223D3D747970656F6620652E72656D6F76654368696C642626652E6174747269627574657320696E7374616E63656F66207A26262266756E6374696F6E223D3D747970656F';
wwv_flow_api.g_varchar2_table(47) := '6620652E72656D6F766541747472696275746526262266756E6374696F6E223D3D747970656F6620652E736574417474726962757465297D2865292972657475726E2043652865292C21303B76617220723D652E6E6F64654E616D652E746F4C6F776572';
wwv_flow_api.g_varchar2_table(48) := '4361736528293B6966287A65282275706F6E53616E6974697A65456C656D656E74222C652C7B7461674E616D653A722C616C6C6F776564546167733A69657D292C2169655B725D7C7C63655B725D297B69662878652626214D655B725D26262266756E63';
wwv_flow_api.g_varchar2_table(49) := '74696F6E223D3D747970656F6620652E696E7365727441646A6163656E7448544D4C297472797B766172206E3D652E696E6E657248544D4C3B652E696E7365727441646A6163656E7448544D4C28224166746572456E64222C423F422E63726561746548';
wwv_flow_api.g_varchar2_table(50) := '544D4C286E293A6E297D63617463682865297B7D72657475726E2043652865292C21307D72657475726E226E6F736372697074223D3D3D722626652E696E6E657248544D4C2E6D61746368282F3C5C2F6E6F7363726970742F69293F2843652865292C21';
wwv_flow_api.g_varchar2_table(51) := '30293A226E6F656D626564223D3D3D722626652E696E6E657248544D4C2E6D61746368282F3C5C2F6E6F656D6265642F69293F2843652865292C2130293A28216D657C7C652E6669727374456C656D656E744368696C647C7C652E636F6E74656E742626';
wwv_flow_api.g_varchar2_table(52) := '652E636F6E74656E742E6669727374456C656D656E744368696C647C7C212F3C2F672E7465737428652E74657874436F6E74656E74297C7C28752E72656D6F7665642E70757368287B656C656D656E743A652E636C6F6E654E6F646528297D292C652E69';
wwv_flow_api.g_varchar2_table(53) := '6E6E657248544D4C3F652E696E6E657248544D4C3D652E696E6E657248544D4C2E7265706C616365282F3C2F672C22266C743B22293A652E696E6E657248544D4C3D652E74657874436F6E74656E742E7265706C616365282F3C2F672C22266C743B2229';
wwv_flow_api.g_varchar2_table(54) := '292C67652626333D3D3D652E6E6F646554797065262628743D28743D28743D652E74657874436F6E74656E74292E7265706C61636528512C22202229292E7265706C616365285A2C222022292C652E74657874436F6E74656E74213D3D74262628752E72';
wwv_flow_api.g_varchar2_table(55) := '656D6F7665642E70757368287B656C656D656E743A652E636C6F6E654E6F646528297D292C652E74657874436F6E74656E743D7429292C7A652822616674657253616E6974697A65456C656D656E7473222C652C6E756C6C292C2131297D2C46653D6675';
wwv_flow_api.g_varchar2_table(56) := '6E6374696F6E28652C742C72297B6966284C65262628226964223D3D3D747C7C226E616D65223D3D3D74292626287220696E20767C7C7220696E205265292972657475726E21313B6966286665262665652E74657374287429293B656C73652069662864';
wwv_flow_api.g_varchar2_table(57) := '65262674652E74657374287429293B656C73657B696628216C655B745D7C7C75655B745D2972657475726E21313B6966284E655B745D293B656C7365206966286F652E7465737428722E7265706C616365286E652C22222929293B656C73652069662822';
wwv_flow_api.g_varchar2_table(58) := '73726322213D3D74262622786C696E6B3A6872656622213D3D747C7C22736372697074223D3D3D657C7C30213D3D722E696E6465784F662822646174613A22297C7C214F655B655D297B696628706526262172652E7465737428722E7265706C61636528';
wwv_flow_api.g_varchar2_table(59) := '6E652C22222929293B656C736520696628722972657475726E21317D656C73653B7D72657475726E21307D2C6A653D66756E6374696F6E2865297B76617220743D766F696420302C723D766F696420302C6E3D766F696420302C6F3D766F696420302C69';
wwv_flow_api.g_varchar2_table(60) := '3D766F696420303B7A6528226265666F726553616E6974697A6541747472696275746573222C652C6E756C6C293B76617220613D652E617474726962757465733B69662861297B766172206C3D7B617474724E616D653A22222C6174747256616C75653A';
wwv_flow_api.g_varchar2_table(61) := '22222C6B656570417474723A21302C616C6C6F776564417474726962757465733A6C657D3B666F7228693D612E6C656E6774683B692D2D3B297B76617220733D743D615B695D2C633D732E6E616D652C643D732E6E616D6573706163655552493B696628';
wwv_flow_api.g_varchar2_table(62) := '723D742E76616C75652E7472696D28292C6E3D632E746F4C6F7765724361736528292C6C2E617474724E616D653D6E2C6C2E6174747256616C75653D722C6C2E6B656570417474723D21302C7A65282275706F6E53616E6974697A654174747269627574';
wwv_flow_api.g_varchar2_table(63) := '65222C652C6C292C723D6C2E6174747256616C75652C226E616D65223D3D3D6E262622494D47223D3D3D652E6E6F64654E616D652626612E6964296F3D612E69642C613D4F284E2C612C5B5D292C6B6528226964222C65292C6B6528632C65292C612E69';
wwv_flow_api.g_varchar2_table(64) := '6E6465784F66286F293E692626652E73657441747472696275746528226964222C6F2E76616C7565293B656C73657B69662822494E505554223D3D3D652E6E6F64654E616D6526262274797065223D3D3D6E26262266696C65223D3D3D722626286C655B';
wwv_flow_api.g_varchar2_table(65) := '6E5D7C7C2175655B6E5D2929636F6E74696E75653B226964223D3D3D632626652E73657441747472696275746528632C2222292C6B6528632C65297D6966286C2E6B65657041747472297B6765262628723D28723D722E7265706C61636528512C222022';
wwv_flow_api.g_varchar2_table(66) := '29292E7265706C616365285A2C22202229293B76617220663D652E6E6F64654E616D652E746F4C6F7765724361736528293B696628466528662C6E2C7229297472797B643F652E7365744174747269627574654E5328642C632C72293A652E7365744174';
wwv_flow_api.g_varchar2_table(67) := '7472696275746528632C72292C752E72656D6F7665642E706F7028297D63617463682865297B7D7D7D7A652822616674657253616E6974697A6541747472696275746573222C652C6E756C6C297D7D2C55653D66756E6374696F6E20652874297B766172';
wwv_flow_api.g_varchar2_table(68) := '20723D766F696420302C6E3D49652874293B666F72287A6528226265666F726553616E6974697A65536861646F77444F4D222C742C6E756C6C293B723D6E2E6E6578744E6F646528293B297A65282275706F6E53616E6974697A65536861646F774E6F64';
wwv_flow_api.g_varchar2_table(69) := '65222C722C6E756C6C292C50652872297C7C28722E636F6E74656E7420696E7374616E63656F66204326266528722E636F6E74656E74292C6A65287229293B7A652822616674657253616E6974697A65536861646F77444F4D222C742C6E756C6C297D3B';
wwv_flow_api.g_varchar2_table(70) := '72657475726E20752E73616E6974697A653D66756E6374696F6E28652C74297B76617220723D766F696420302C6E3D766F696420302C693D766F696420302C613D766F696420302C6C3D766F696420303B696628657C7C28653D225C783363212D2D5C78';
wwv_flow_api.g_varchar2_table(71) := '336522292C22737472696E6722213D747970656F6620652626214865286529297B6966282266756E6374696F6E22213D747970656F6620652E746F537472696E67297468726F77206E657720547970654572726F722822746F537472696E67206973206E';
wwv_flow_api.g_varchar2_table(72) := '6F7420612066756E6374696F6E22293B69662822737472696E6722213D747970656F6628653D652E746F537472696E67282929297468726F77206E657720547970654572726F7228226469727479206973206E6F74206120737472696E672C2061626F72';
wwv_flow_api.g_varchar2_table(73) := '74696E6722297D69662821752E6973537570706F72746564297B696628226F626A656374223D3D3D4D286F2E746F53746174696348544D4C297C7C2266756E6374696F6E223D3D747970656F66206F2E746F53746174696348544D4C297B696628227374';
wwv_flow_api.g_varchar2_table(74) := '72696E67223D3D747970656F6620652972657475726E206F2E746F53746174696348544D4C2865293B69662848652865292972657475726E206F2E746F53746174696348544D4C28652E6F7574657248544D4C297D72657475726E20657D69662879657C';
wwv_flow_api.g_varchar2_table(75) := '7C5F652874292C752E72656D6F7665643D5B5D2C4165293B656C7365206966286520696E7374616E63656F66204429313D3D3D286E3D28723D446528225C783363212D2D5C7833652229292E6F776E6572446F63756D656E742E696D706F72744E6F6465';
wwv_flow_api.g_varchar2_table(76) := '28652C213029292E6E6F646554797065262622424F4459223D3D3D6E2E6E6F64654E616D653F723D6E3A2248544D4C223D3D3D6E2E6E6F64654E616D653F723D6E3A722E617070656E644368696C64286E293B656C73657B696628216265262621676526';
wwv_flow_api.g_varchar2_table(77) := '2621686526262D313D3D3D652E696E6465784F6628223C22292972657475726E20423F422E63726561746548544D4C2865293A653B6966282128723D4465286529292972657475726E2062653F6E756C6C3A567D72262676652626436528722E66697273';
wwv_flow_api.g_varchar2_table(78) := '744368696C64293B666F722876617220733D49652841653F653A72293B693D732E6E6578744E6F646528293B29333D3D3D692E6E6F6465547970652626693D3D3D617C7C50652869297C7C28692E636F6E74656E7420696E7374616E63656F6620432626';
wwv_flow_api.g_varchar2_table(79) := '556528692E636F6E74656E74292C6A652869292C613D69293B696628613D6E756C6C2C41652972657475726E20653B6966286265297B696628546529666F72286C3D582E63616C6C28722E6F776E6572446F63756D656E74293B722E6669727374436869';
wwv_flow_api.g_varchar2_table(80) := '6C643B296C2E617070656E644368696C6428722E66697273744368696C64293B656C7365206C3D723B72657475726E2045652626286C3D4A2E63616C6C28672C6C2C213029292C6C7D76617220633D68653F722E6F7574657248544D4C3A722E696E6E65';
wwv_flow_api.g_varchar2_table(81) := '7248544D4C3B72657475726E206765262628633D28633D632E7265706C61636528512C22202229292E7265706C616365285A2C22202229292C423F422E63726561746548544D4C2863293A637D2C752E736574436F6E6669673D66756E6374696F6E2865';
wwv_flow_api.g_varchar2_table(82) := '297B5F652865292C79653D21307D2C752E636C656172436F6E6669673D66756E6374696F6E28297B77653D6E756C6C2C79653D21317D2C752E697356616C69644174747269627574653D66756E6374696F6E28652C742C72297B77657C7C5F65287B7D29';
wwv_flow_api.g_varchar2_table(83) := '3B766172206E3D652E746F4C6F7765724361736528292C6F3D742E746F4C6F7765724361736528293B72657475726E204665286E2C6F2C72297D2C752E616464486F6F6B3D66756E6374696F6E28652C74297B2266756E6374696F6E223D3D747970656F';
wwv_flow_api.g_varchar2_table(84) := '6620742626284B5B655D3D4B5B655D7C7C5B5D2C4B5B655D2E70757368287429297D2C752E72656D6F7665486F6F6B3D66756E6374696F6E2865297B4B5B655D26264B5B655D2E706F7028297D2C752E72656D6F7665486F6F6B733D66756E6374696F6E';
wwv_flow_api.g_varchar2_table(85) := '2865297B4B5B655D2626284B5B655D3D5B5D297D2C752E72656D6F7665416C6C486F6F6B733D66756E6374696F6E28297B4B3D7B7D7D2C757D766172206F3D4F626A6563742E667265657A657C7C66756E6374696F6E2865297B72657475726E20657D2C';
wwv_flow_api.g_varchar2_table(86) := '693D6F285B2261222C2261626272222C226163726F6E796D222C2261646472657373222C2261726561222C2261727469636C65222C226173696465222C22617564696F222C2262222C22626469222C2262646F222C22626967222C22626C696E6B222C22';
wwv_flow_api.g_varchar2_table(87) := '626C6F636B71756F7465222C22626F6479222C226272222C22627574746F6E222C2263616E766173222C2263617074696F6E222C2263656E746572222C2263697465222C22636F6465222C22636F6C222C22636F6C67726F7570222C22636F6E74656E74';
wwv_flow_api.g_varchar2_table(88) := '222C2264617461222C22646174616C697374222C226464222C226465636F7261746F72222C2264656C222C2264657461696C73222C2264666E222C22646972222C22646976222C22646C222C226474222C22656C656D656E74222C22656D222C22666965';
wwv_flow_api.g_varchar2_table(89) := '6C64736574222C2266696763617074696F6E222C22666967757265222C22666F6E74222C22666F6F746572222C22666F726D222C226831222C226832222C226833222C226834222C226835222C226836222C2268656164222C22686561646572222C2268';
wwv_flow_api.g_varchar2_table(90) := '67726F7570222C226872222C2268746D6C222C2269222C22696D67222C22696E707574222C22696E73222C226B6264222C226C6162656C222C226C6567656E64222C226C69222C226D61696E222C226D6170222C226D61726B222C226D61727175656522';
wwv_flow_api.g_varchar2_table(91) := '2C226D656E75222C226D656E756974656D222C226D65746572222C226E6176222C226E6F6272222C226F6C222C226F707467726F7570222C226F7074696F6E222C226F7574707574222C2270222C22707265222C2270726F6772657373222C2271222C22';
wwv_flow_api.g_varchar2_table(92) := '7270222C227274222C2272756279222C2273222C2273616D70222C2273656374696F6E222C2273656C656374222C22736861646F77222C22736D616C6C222C22736F75726365222C22737061636572222C227370616E222C22737472696B65222C227374';
wwv_flow_api.g_varchar2_table(93) := '726F6E67222C227374796C65222C22737562222C2273756D6D617279222C22737570222C227461626C65222C2274626F6479222C227464222C2274656D706C617465222C227465787461726561222C2274666F6F74222C227468222C227468656164222C';
wwv_flow_api.g_varchar2_table(94) := '2274696D65222C227472222C22747261636B222C227474222C2275222C22756C222C22766172222C22766964656F222C22776272225D292C613D6F285B22737667222C2261222C22616C74676C797068222C22616C74676C797068646566222C22616C74';
wwv_flow_api.g_varchar2_table(95) := '676C7970686974656D222C22616E696D617465636F6C6F72222C22616E696D6174656D6F74696F6E222C22616E696D6174657472616E73666F726D222C22617564696F222C2263616E766173222C22636972636C65222C22636C697070617468222C2264';
wwv_flow_api.g_varchar2_table(96) := '656673222C2264657363222C22656C6C69707365222C2266696C746572222C22666F6E74222C2267222C22676C797068222C22676C797068726566222C22686B65726E222C22696D616765222C226C696E65222C226C696E6561726772616469656E7422';
wwv_flow_api.g_varchar2_table(97) := '2C226D61726B6572222C226D61736B222C226D65746164617461222C226D70617468222C2270617468222C227061747465726E222C22706F6C79676F6E222C22706F6C796C696E65222C2272616469616C6772616469656E74222C2272656374222C2273';
wwv_flow_api.g_varchar2_table(98) := '746F70222C227374796C65222C22737769746368222C2273796D626F6C222C2274657874222C227465787470617468222C227469746C65222C2274726566222C22747370616E222C22766964656F222C2276696577222C22766B65726E225D292C6C3D6F';
wwv_flow_api.g_varchar2_table(99) := '285B226665426C656E64222C226665436F6C6F724D6174726978222C226665436F6D706F6E656E745472616E73666572222C226665436F6D706F73697465222C226665436F6E766F6C76654D6174726978222C226665446966667573654C69676874696E';
wwv_flow_api.g_varchar2_table(100) := '67222C226665446973706C6163656D656E744D6170222C22666544697374616E744C69676874222C226665466C6F6F64222C22666546756E6341222C22666546756E6342222C22666546756E6347222C22666546756E6352222C22666547617573736961';
wwv_flow_api.g_varchar2_table(101) := '6E426C7572222C2266654D65726765222C2266654D657267654E6F6465222C2266654D6F7270686F6C6F6779222C2266654F6666736574222C226665506F696E744C69676874222C22666553706563756C61724C69676874696E67222C22666553706F74';
wwv_flow_api.g_varchar2_table(102) := '4C69676874222C22666554696C65222C22666554757262756C656E6365225D292C733D6F285B226D617468222C226D656E636C6F7365222C226D6572726F72222C226D66656E636564222C226D66726163222C226D676C797068222C226D69222C226D6C';
wwv_flow_api.g_varchar2_table(103) := '6162656C65647472222C226D6D756C746973637269707473222C226D6E222C226D6F222C226D6F766572222C226D706164646564222C226D7068616E746F6D222C226D726F6F74222C226D726F77222C226D73222C226D7370616365222C226D73717274';
wwv_flow_api.g_varchar2_table(104) := '222C226D7374796C65222C226D737562222C226D737570222C226D737562737570222C226D7461626C65222C226D7464222C226D74657874222C226D7472222C226D756E646572222C226D756E6465726F766572225D292C633D6F285B22237465787422';
wwv_flow_api.g_varchar2_table(105) := '5D292C753D4F626A6563742E667265657A657C7C66756E6374696F6E2865297B72657475726E20657D2C643D75285B22616363657074222C22616374696F6E222C22616C69676E222C22616C74222C226175746F636F6D706C657465222C226261636B67';
wwv_flow_api.g_varchar2_table(106) := '726F756E64222C226267636F6C6F72222C22626F72646572222C2263656C6C70616464696E67222C2263656C6C73706163696E67222C22636865636B6564222C2263697465222C22636C617373222C22636C656172222C22636F6C6F72222C22636F6C73';
wwv_flow_api.g_varchar2_table(107) := '222C22636F6C7370616E222C22636F6F726473222C2263726F73736F726967696E222C226461746574696D65222C2264656661756C74222C22646972222C2264697361626C6564222C22646F776E6C6F6164222C22656E6374797065222C226661636522';
wwv_flow_api.g_varchar2_table(108) := '2C22666F72222C2268656164657273222C22686569676874222C2268696464656E222C2268696768222C2268726566222C22687265666C616E67222C226964222C22696E74656772697479222C2269736D6170222C226C6162656C222C226C616E67222C';
wwv_flow_api.g_varchar2_table(109) := '226C697374222C226C6F6F70222C226C6F77222C226D6178222C226D61786C656E677468222C226D65646961222C226D6574686F64222C226D696E222C226D756C7469706C65222C226E616D65222C226E6F7368616465222C226E6F76616C6964617465';
wwv_flow_api.g_varchar2_table(110) := '222C226E6F77726170222C226F70656E222C226F7074696D756D222C227061747465726E222C22706C616365686F6C646572222C22706F73746572222C227072656C6F6164222C2270756264617465222C22726164696F67726F7570222C22726561646F';
wwv_flow_api.g_varchar2_table(111) := '6E6C79222C2272656C222C227265717569726564222C22726576222C227265766572736564222C22726F6C65222C22726F7773222C22726F777370616E222C227370656C6C636865636B222C2273636F7065222C2273656C6563746564222C2273686170';
wwv_flow_api.g_varchar2_table(112) := '65222C2273697A65222C2273697A6573222C227370616E222C227372636C616E67222C227374617274222C22737263222C22737263736574222C2273746570222C227374796C65222C2273756D6D617279222C22746162696E646578222C227469746C65';
wwv_flow_api.g_varchar2_table(113) := '222C2274797065222C227573656D6170222C2276616C69676E222C2276616C7565222C227769647468222C22786D6C6E73225D292C663D75285B22616363656E742D686569676874222C22616363756D756C617465222C226164646974697665222C2261';
wwv_flow_api.g_varchar2_table(114) := '6C69676E6D656E742D626173656C696E65222C22617363656E74222C226174747269627574656E616D65222C2261747472696275746574797065222C22617A696D757468222C22626173656672657175656E6379222C22626173656C696E652D73686966';
wwv_flow_api.g_varchar2_table(115) := '74222C22626567696E222C2262696173222C226279222C22636C617373222C22636C6970222C22636C69702D70617468222C22636C69702D72756C65222C22636F6C6F72222C22636F6C6F722D696E746572706F6C6174696F6E222C22636F6C6F722D69';
wwv_flow_api.g_varchar2_table(116) := '6E746572706F6C6174696F6E2D66696C74657273222C22636F6C6F722D70726F66696C65222C22636F6C6F722D72656E646572696E67222C226378222C226379222C2264222C226478222C226479222C2264696666757365636F6E7374616E74222C2264';
wwv_flow_api.g_varchar2_table(117) := '6972656374696F6E222C22646973706C6179222C2264697669736F72222C22647572222C22656467656D6F6465222C22656C65766174696F6E222C22656E64222C2266696C6C222C2266696C6C2D6F706163697479222C2266696C6C2D72756C65222C22';
wwv_flow_api.g_varchar2_table(118) := '66696C746572222C22666C6F6F642D636F6C6F72222C22666C6F6F642D6F706163697479222C22666F6E742D66616D696C79222C22666F6E742D73697A65222C22666F6E742D73697A652D61646A757374222C22666F6E742D73747265746368222C2266';
wwv_flow_api.g_varchar2_table(119) := '6F6E742D7374796C65222C22666F6E742D76617269616E74222C22666F6E742D776569676874222C226678222C226679222C226731222C226732222C22676C7970682D6E616D65222C22676C797068726566222C226772616469656E74756E697473222C';
wwv_flow_api.g_varchar2_table(120) := '226772616469656E747472616E73666F726D222C22686569676874222C2268726566222C226964222C22696D6167652D72656E646572696E67222C22696E222C22696E32222C226B222C226B31222C226B32222C226B33222C226B34222C226B65726E69';
wwv_flow_api.g_varchar2_table(121) := '6E67222C226B6579706F696E7473222C226B657973706C696E6573222C226B657974696D6573222C226C616E67222C226C656E67746861646A757374222C226C65747465722D73706163696E67222C226B65726E656C6D6174726978222C226B65726E65';
wwv_flow_api.g_varchar2_table(122) := '6C756E69746C656E677468222C226C69676874696E672D636F6C6F72222C226C6F63616C222C226D61726B65722D656E64222C226D61726B65722D6D6964222C226D61726B65722D7374617274222C226D61726B6572686569676874222C226D61726B65';
wwv_flow_api.g_varchar2_table(123) := '72756E697473222C226D61726B65727769647468222C226D61736B636F6E74656E74756E697473222C226D61736B756E697473222C226D6178222C226D61736B222C226D65646961222C226D6574686F64222C226D6F6465222C226D696E222C226E616D';
wwv_flow_api.g_varchar2_table(124) := '65222C226E756D6F637461766573222C226F6666736574222C226F70657261746F72222C226F706163697479222C226F72646572222C226F7269656E74222C226F7269656E746174696F6E222C226F726967696E222C226F766572666C6F77222C227061';
wwv_flow_api.g_varchar2_table(125) := '696E742D6F72646572222C2270617468222C22706174686C656E677468222C227061747465726E636F6E74656E74756E697473222C227061747465726E7472616E73666F726D222C227061747465726E756E697473222C22706F696E7473222C22707265';
wwv_flow_api.g_varchar2_table(126) := '7365727665616C706861222C227072657365727665617370656374726174696F222C2272222C227278222C227279222C22726164697573222C2272656678222C2272656679222C22726570656174636F756E74222C22726570656174647572222C227265';
wwv_flow_api.g_varchar2_table(127) := '7374617274222C22726573756C74222C22726F74617465222C227363616C65222C2273656564222C2273686170652D72656E646572696E67222C2273706563756C6172636F6E7374616E74222C2273706563756C61726578706F6E656E74222C22737072';
wwv_flow_api.g_varchar2_table(128) := '6561646D6574686F64222C22737464646576696174696F6E222C2273746974636874696C6573222C2273746F702D636F6C6F72222C2273746F702D6F706163697479222C227374726F6B652D646173686172726179222C227374726F6B652D646173686F';
wwv_flow_api.g_varchar2_table(129) := '6666736574222C227374726F6B652D6C696E65636170222C227374726F6B652D6C696E656A6F696E222C227374726F6B652D6D697465726C696D6974222C227374726F6B652D6F706163697479222C227374726F6B65222C227374726F6B652D77696474';
wwv_flow_api.g_varchar2_table(130) := '68222C227374796C65222C22737572666163657363616C65222C22746162696E646578222C2274617267657478222C2274617267657479222C227472616E73666F726D222C22746578742D616E63686F72222C22746578742D6465636F726174696F6E22';
wwv_flow_api.g_varchar2_table(131) := '2C22746578742D72656E646572696E67222C22746578746C656E677468222C2274797065222C227531222C227532222C22756E69636F6465222C2276616C756573222C2276696577626F78222C227669736962696C697479222C2276657273696F6E222C';
wwv_flow_api.g_varchar2_table(132) := '22766572742D6164762D79222C22766572742D6F726967696E2D78222C22766572742D6F726967696E2D79222C227769647468222C22776F72642D73706163696E67222C2277726170222C2277726974696E672D6D6F6465222C22786368616E6E656C73';
wwv_flow_api.g_varchar2_table(133) := '656C6563746F72222C22796368616E6E656C73656C6563746F72222C2278222C227831222C227832222C22786D6C6E73222C2279222C227931222C227932222C227A222C227A6F6F6D616E6470616E225D292C703D75285B22616363656E74222C226163';
wwv_flow_api.g_varchar2_table(134) := '63656E74756E646572222C22616C69676E222C22626576656C6C6564222C22636C6F7365222C22636F6C756D6E73616C69676E222C22636F6C756D6E6C696E6573222C22636F6C756D6E7370616E222C2264656E6F6D616C69676E222C22646570746822';
wwv_flow_api.g_varchar2_table(135) := '2C22646972222C22646973706C6179222C22646973706C61797374796C65222C2266656E6365222C226672616D65222C22686569676874222C2268726566222C226964222C226C617267656F70222C226C656E677468222C226C696E65746869636B6E65';
wwv_flow_api.g_varchar2_table(136) := '7373222C226C7370616365222C226C71756F7465222C226D6174686261636B67726F756E64222C226D617468636F6C6F72222C226D61746873697A65222C226D61746876617269616E74222C226D617873697A65222C226D696E73697A65222C226D6F76';
wwv_flow_api.g_varchar2_table(137) := '61626C656C696D697473222C226E6F746174696F6E222C226E756D616C69676E222C226F70656E222C22726F77616C69676E222C22726F776C696E6573222C22726F7773706163696E67222C22726F777370616E222C22727370616365222C227271756F';
wwv_flow_api.g_varchar2_table(138) := '7465222C227363726970746C6576656C222C227363726970746D696E73697A65222C2273637269707473697A656D756C7469706C696572222C2273656C656374696F6E222C22736570617261746F72222C22736570617261746F7273222C227374726574';
wwv_flow_api.g_varchar2_table(139) := '636879222C227375627363726970747368696674222C227375707363726970747368696674222C2273796D6D6574726963222C22766F6666736574222C227769647468222C22786D6C6E73225D292C6D3D75285B22786C696E6B3A68726566222C22786D';
wwv_flow_api.g_varchar2_table(140) := '6C3A6964222C22786C696E6B3A7469746C65222C22786D6C3A7370616365222C22786D6C6E733A786C696E6B225D292C673D4F626A6563742E6861734F776E50726F70657274792C683D4F626A6563742E73657450726F746F747970654F662C793D2822';
wwv_flow_api.g_varchar2_table(141) := '756E646566696E656422213D747970656F66205265666C65637426265265666C656374292E6170706C793B797C7C28793D66756E6374696F6E28652C742C72297B72657475726E20652E6170706C7928742C72297D293B76617220763D4F626A6563742E';
wwv_flow_api.g_varchar2_table(142) := '7365616C7C7C66756E6374696F6E2865297B72657475726E20657D2C623D76282F5C7B5C7B5B5C735C535D2A7C5B5C735C535D2A5C7D5C7D2F676D292C543D76282F3C255B5C735C535D2A7C5B5C735C535D2A253E2F676D292C453D76282F5E64617461';
wwv_flow_api.g_varchar2_table(143) := '2D5B5C2D5C772E5C75303042372D5C75464646465D2F292C4C3D76282F5E617269612D5B5C2D5C775D2B242F292C783D76282F5E283F3A283F3A283F3A667C6874297470733F7C6D61696C746F7C74656C7C63616C6C746F7C6369647C786D7070293A7C';
wwv_flow_api.g_varchar2_table(144) := '5B5E612D7A5D7C5B612D7A2B2E5C2D5D2B283F3A5B5E612D7A2B2E5C2D3A5D7C2429292F69292C413D76282F5E283F3A5C772B7363726970747C64617461293A2F69292C533D76282F5B5C75303030302D5C75303032305C75303041305C75313638305C';
wwv_flow_api.g_varchar2_table(145) := '75313830455C75323030302D5C75323032395C75323035665C75333030305D2F67292C4D3D2266756E6374696F6E223D3D747970656F662053796D626F6C26262273796D626F6C223D3D747970656F662053796D626F6C2E6974657261746F723F66756E';
wwv_flow_api.g_varchar2_table(146) := '6374696F6E2865297B72657475726E20747970656F6620657D3A66756E6374696F6E2865297B72657475726E206526262266756E6374696F6E223D3D747970656F662053796D626F6C2626652E636F6E7374727563746F723D3D3D53796D626F6C262665';
wwv_flow_api.g_varchar2_table(147) := '213D3D53796D626F6C2E70726F746F747970653F2273796D626F6C223A747970656F6620657D2C4F3D2822756E646566696E656422213D747970656F66205265666C65637426265265666C656374292E6170706C792C4E3D41727261792E70726F746F74';
wwv_flow_api.g_varchar2_table(148) := '7970652E736C6963652C773D4F626A6563742E667265657A652C523D66756E6374696F6E28297B72657475726E22756E646566696E6564223D3D747970656F662077696E646F773F6E756C6C3A77696E646F777D3B4F7C7C284F3D66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(149) := '652C742C72297B72657475726E20652E6170706C7928742C72297D293B766172205F3D66756E6374696F6E28652C74297B696628226F626A65637422213D3D28766F696420303D3D3D653F22756E646566696E6564223A4D286529297C7C2266756E6374';
wwv_flow_api.g_varchar2_table(150) := '696F6E22213D747970656F6620652E637265617465506F6C6963792972657475726E206E756C6C3B76617220723D6E756C6C2C6E3D22646174612D74742D706F6C6963792D737566666978223B742E63757272656E745363726970742626742E63757272';
wwv_flow_api.g_varchar2_table(151) := '656E745363726970742E686173417474726962757465286E29262628723D742E63757272656E745363726970742E676574417474726962757465286E29293B766172206F3D22646F6D707572696679222B28723F2223222B723A2222293B7472797B7265';
wwv_flow_api.g_varchar2_table(152) := '7475726E20652E637265617465506F6C696379286F2C7B63726561746548544D4C3A66756E6374696F6E2865297B72657475726E20657D7D297D63617463682865297B72657475726E20636F6E736F6C652E7761726E2822547275737465645479706573';
wwv_flow_api.g_varchar2_table(153) := '20706F6C69637920222B6F2B2220636F756C64206E6F7420626520637265617465642E22292C6E756C6C7D7D3B72657475726E206E28297D293B76617220636C6F624C6F61643D66756E6374696F6E28297B2275736520737472696374223B66756E6374';
wwv_flow_api.g_varchar2_table(154) := '696F6E207428652C74297B72657475726E20444F4D5075726966792E73616E6974697A6528652C742E73616E6974697A654F7074696F6E73297D66756E6374696F6E207228652C722C6F297B7472797B6E2E64656275672E696E666F2865292C652E726F';
wwv_flow_api.g_varchar2_table(155) := '772626652E726F772E6C656E6774683E302626242E6561636828652E726F772C66756E6374696F6E28652C6F297B6F2E454C454D454E545F53454C4543544F5226266F2E434C4F425F56414C55452626286F2E454C454D454E545F545950453F22646F6D';
wwv_flow_api.g_varchar2_table(156) := '223D3D6F2E454C454D454E545F545950453F66756E6374696F6E28652C722C6F297B76617220693B69662865297B696628242865292E656D70747928292C722626722E6C656E6774683E30297B696628693D6F2E73616E6974697A653F7428722C6F293A';
wwv_flow_api.g_varchar2_table(157) := '722C6F2E65736361706548544D4C29242865292E746578742869293B656C7365206966286F2E75736555525445496D674C6F61646572297B76617220613D2428223C6469763E3C2F6469763E22292C6C3D6F2E6974656D73325375626D6974496D673B74';
wwv_flow_api.g_varchar2_table(158) := '72797B612E68746D6C2869293B76617220733D612E66696E642827696D675B616C742A3D2261696823225D27293B242E6561636828732C66756E6374696F6E28652C74297B696628742E7469746C65297B76617220723D742E7469746C652C693D617065';
wwv_flow_api.g_varchar2_table(159) := '782E7365727665722E706C7567696E55726C286F2E616A617849442C7B7830313A225052494E545F494D414745222C7830333A722C706167654974656D733A6C7D293B742E7372633D697D656C7365206E2E64656275672E6572726F722822696D672069';
wwv_flow_api.g_varchar2_table(160) := '6E207269636874657874656469746F7220686173206E6F207469746C652E205469746C6520697320757365642061207072696D617279206B657920746F2067657420696D6167652066726F6D2064622E22297D292C242865292E68746D6C28615B305D2E';
wwv_flow_api.g_varchar2_table(161) := '696E6E657248544D4C297D63617463682865297B6E2E64656275672E6572726F7228224572726F72207768696C652074727920746F206C6F616420696D61676573207768656E206C6F6164696E672072696368207465787420656469746F722E22292C6E';
wwv_flow_api.g_varchar2_table(162) := '2E64656275672E6572726F722865297D7D656C736520242865292E68746D6C2869293B617065782E6576656E742E7472696767657228652C22636C6F6272656E646572636F6D706C65746522297D7D656C7365206E2E64656275672E6572726F7228224E';
wwv_flow_api.g_varchar2_table(163) := '6F20454C454D454E545F53454C4543544F522073657420696E2053514C20666F7220434C4F422052656E64657222297D286F2E454C454D454E545F53454C4543544F522C6F2E434C4F425F56414C55452C72293A226974656D223D3D6F2E454C454D454E';
wwv_flow_api.g_varchar2_table(164) := '545F545950453F66756E6374696F6E28652C722C6F297B76617220692C613D21313B6966286529696628722626722E6C656E6774683E30297B696628693D6F2E73616E6974697A653F7428722C6F293A722C6F2E65736361706548544D4C29693D6E2E65';
wwv_flow_api.g_varchar2_table(165) := '736361706548544D4C2872293B656C7365206966286F2E75736555525445496D674C6F61646572297B766172206C3D2428223C6469763E3C2F6469763E22292C733D6F2E6974656D73325375626D6974496D673B7472797B6C2E68746D6C2869293B7661';
wwv_flow_api.g_varchar2_table(166) := '7220633D6C2E66696E642827696D675B616C742A3D2261696823225D27293B242E6561636828632C66756E6374696F6E28652C74297B696628742E7469746C65297B76617220723D742E7469746C652C693D617065782E7365727665722E706C7567696E';
wwv_flow_api.g_varchar2_table(167) := '55726C286F2E616A617849442C7B7830313A225052494E545F494D414745222C7830333A722C706167654974656D733A737D293B742E7372633D697D656C7365206E2E64656275672E6572726F722822696D6720696E207269636874657874656469746F';
wwv_flow_api.g_varchar2_table(168) := '7220686173206E6F207469746C652E205469746C6520697320757365642061207072696D617279206B657920746F2067657420696D6167652066726F6D2064622E22297D292C693D6C5B305D2E696E6E657248544D4C7D63617463682865297B6E2E6465';
wwv_flow_api.g_varchar2_table(169) := '6275672E6572726F7228224572726F72207768696C652074727920746F206C6F616420696D61676573207768656E206C6F6164696E672072696368207465787420656469746F722E22292C6E2E64656275672E6572726F722865297D7D2D31213D3D6170';
wwv_flow_api.g_varchar2_table(170) := '65782E6974656D2865292E6974656D5F747970652E696E6465784F662822434B454449544F5222293F28434B454449544F522E6F6E2822696E7374616E63655265616479222C66756E6374696F6E2874297B2130213D3D612626286E2E64656275672E69';
wwv_flow_api.g_varchar2_table(171) := '6E666F2822434B454449544F5220696E7374616E6365526561647920666972656422292C6E2E7365744974656D56616C756528652C69292C434B454449544F522E696E7374616E6365735B655D2E6F6E2822636F6E74656E74446F6D222C66756E637469';
wwv_flow_api.g_varchar2_table(172) := '6F6E28297B617065782E6576656E742E74726967676572282223222B652C22636C6F6272656E646572636F6D706C65746522297D292C613D2130297D292C73657454696D656F75742866756E6374696F6E28297B2130213D3D612626286E2E6465627567';
wwv_flow_api.g_varchar2_table(173) := '2E696E666F28224E6F20496E7374616E6365205265616479206576656E742066726F6D20434B454449544F5222292C6E2E7365744974656D56616C756528652C69292C434B454449544F522E696E7374616E6365735B655D2E6F6E2822636F6E74656E74';
wwv_flow_api.g_varchar2_table(174) := '446F6D222C66756E6374696F6E28297B617065782E6576656E742E74726967676572282223222B652C22636C6F6272656E646572636F6D706C65746522297D292C613D2130297D2C37353029293A286E2E7365744974656D56616C756528652C69292C61';
wwv_flow_api.g_varchar2_table(175) := '7065782E6576656E742E74726967676572282223222B652C22636C6F6272656E646572636F6D706C6574652229297D656C736520617065782E6576656E742E74726967676572282223222B652C22636C6F6272656E646572636F6D706C65746522293B65';
wwv_flow_api.g_varchar2_table(176) := '6C7365206E2E64656275672E6572726F7228224E6F20454C454D454E545F53454C4543544F522073657420696E2053514C20666F7220434C4F422052656E64657222297D286F2E454C454D454E545F53454C4543544F522C6F2E434C4F425F56414C5545';
wwv_flow_api.g_varchar2_table(177) := '2C72293A6E2E64656275672E6572726F722822454C454D454E545F54595045206D7573742062653A20646F6D2C206974656D20616E64206E6F7420222B6F2E454C454D454E545F54595045293A6E2E64656275672E6572726F722822454C454D454E545F';
wwv_flow_api.g_varchar2_table(178) := '54595045206973206E756C6C20696E2053514C20666F7220434C4F422052656E6465722229297D292C242E6561636828722E616666456C656D656E74732C66756E6374696F6E28652C74297B6E2E6C6F616465722E73746F702874292C617065782E6576';
wwv_flow_api.g_varchar2_table(179) := '656E742E7472696767657228742C22636C6F6272656E646572636F6D706C65746522297D297D63617463682865297B6E2E64656275672E6572726F7228224572726F72207768696C652072656E64657220434C4F4222292C6E2E64656275672E6572726F';
wwv_flow_api.g_varchar2_table(180) := '722865297D7D766172206E3D7B76657273696F6E3A22312E302E35222C6973415045583A66756E6374696F6E28297B72657475726E22756E646566696E656422213D747970656F6620617065787D2C64656275673A7B696E666F3A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(181) := '65297B6E2E69734150455828292626617065782E64656275672E696E666F2865297D2C6572726F723A66756E6374696F6E2865297B6E2E69734150455828293F617065782E64656275672E6572726F722865293A636F6E736F6C652E6572726F72286529';
wwv_flow_api.g_varchar2_table(182) := '7D7D2C65736361706548544D4C3A66756E6374696F6E2865297B6966286E756C6C3D3D3D652972657475726E206E756C6C3B696628766F69642030213D3D65297B696628226F626A656374223D3D747970656F662065297472797B653D4A534F4E2E7374';
wwv_flow_api.g_varchar2_table(183) := '72696E676966792865297D63617463682865297B7D72657475726E206E2E69734150455828293F617065782E7574696C2E65736361706548544D4C28537472696E67286529293A28653D537472696E67286529292E7265706C616365282F262F672C2226';
wwv_flow_api.g_varchar2_table(184) := '616D703B22292E7265706C616365282F3C2F672C22266C743B22292E7265706C616365282F3E2F672C222667743B22292E7265706C616365282F222F672C222671756F743B22292E7265706C616365282F272F672C2226237832373B22292E7265706C61';
wwv_flow_api.g_varchar2_table(185) := '6365282F5C2F2F672C2226237832463B22297D7D2C756E45736361706548544D4C3A66756E6374696F6E2865297B6966286E756C6C3D3D3D652972657475726E206E756C6C3B696628766F69642030213D3D65297B696628226F626A656374223D3D7479';
wwv_flow_api.g_varchar2_table(186) := '70656F662065297472797B653D4A534F4E2E737472696E676966792865297D63617463682865297B7D72657475726E28653D537472696E67286529292E7265706C616365282F26616D703B2F672C222622292E7265706C616365282F266C743B2F672C22';
wwv_flow_api.g_varchar2_table(187) := '3C22292E7265706C616365282F2667743B2F672C223E22292E7265706C616365282F2671756F743B2F672C272227292E7265706C616365282F237832373B2F672C222722292E7265706C616365282F26237832463B2F672C225C5C22297D7D2C6C6F6164';
wwv_flow_api.g_varchar2_table(188) := '65723A7B73746172743A66756E6374696F6E2865297B6966286E2E697341504558282929617065782E7574696C2E73686F775370696E6E65722824286529293B656C73657B76617220743D2428223C7370616E3E3C2F7370616E3E22293B742E61747472';
wwv_flow_api.g_varchar2_table(189) := '28226964222C226C6F61646572222B65292C742E616464436C617373282263742D6C6F6164657222293B76617220723D2428223C693E3C2F693E22293B722E616464436C617373282266612066612D726566726573682066612D32782066612D616E696D';
wwv_flow_api.g_varchar2_table(190) := '2D7370696E22292C722E63737328226261636B67726F756E64222C2272676261283132312C3132312C3132312C302E362922292C722E6373732822626F726465722D726164697573222C223130302522292C722E637373282270616464696E67222C2231';
wwv_flow_api.g_varchar2_table(191) := '35707822292C722E6373732822636F6C6F72222C22776869746522292C742E617070656E642872292C242865292E617070656E642874297D7D2C73746F703A66756E6374696F6E2865297B2428652B22203E202E752D50726F63657373696E6722292E72';
wwv_flow_api.g_varchar2_table(192) := '656D6F766528292C2428652B22203E202E63742D6C6F6164657222292E72656D6F766528297D7D2C7365744974656D56616C75653A66756E6374696F6E28742C72297B6E2E69734150455828293F617065782E6974656D287429262630213D617065782E';
wwv_flow_api.g_varchar2_table(193) := '6974656D2874292E6E6F64653F617065782E6974656D2874292E73657456616C75652872293A636F6E736F6C652E6572726F722822506C656173652063686F6F7365206120736574206974656D2E2042656361757365207468652076616C75652028222B';
wwv_flow_api.g_varchar2_table(194) := '722B22292063616E206E6F7420626520736574206F6E206974656D2028222B742B222922293A636F6E736F6C652E6572726F7228224572726F72207768696C652074727920746F2063616C6C20617065782E6974656D222B65297D2C6765744974656D56';
wwv_flow_api.g_varchar2_table(195) := '616C75653A66756E6374696F6E2874297B69662821742972657475726E22223B6966286E2E6973415045582829297B696628617065782E6974656D287429262630213D617065782E6974656D2874292E6E6F64652972657475726E20617065782E697465';
wwv_flow_api.g_varchar2_table(196) := '6D2874292E67657456616C756528293B636F6E736F6C652E6572726F722822506C656173652063686F6F7365206120676574206974656D2E2042656361757365207468652076616C756520636F756C64206E6F74206265206765742066726F6D20697465';
wwv_flow_api.g_varchar2_table(197) := '6D28222B742B222922297D656C736520636F6E736F6C652E6572726F7228224572726F72207768696C652074727920746F2063616C6C20617065782E6974656D222B65297D2C6A736F6E53617665457874656E643A66756E6374696F6E28652C74297B76';
wwv_flow_api.g_varchar2_table(198) := '617220723D7B7D3B69662822737472696E67223D3D747970656F662074297472797B743D4A534F4E2E70617273652874297D63617463682865297B636F6E736F6C652E6572726F7228224572726F72207768696C652074727920746F2070617273652074';
wwv_flow_api.g_varchar2_table(199) := '6172676574436F6E6669672E20506C6561736520636865636B20796F757220436F6E666967204A534F4E2E205374616E6461726420436F6E6669672077696C6C20626520757365642E22292C636F6E736F6C652E6572726F722865292C636F6E736F6C65';
wwv_flow_api.g_varchar2_table(200) := '2E6572726F722874297D656C736520723D743B7472797B723D242E657874656E642821302C652C74297D63617463682874297B636F6E736F6C652E6572726F7228224572726F72207768696C652074727920746F206D657267652032204A534F4E732069';
wwv_flow_api.g_varchar2_table(201) := '6E746F207374616E64617264204A534F4E20696620616E7920617474726962757465206973206D697373696E672E20506C6561736520636865636B20796F757220436F6E666967204A534F4E2E205374616E6461726420436F6E6669672077696C6C2062';
wwv_flow_api.g_varchar2_table(202) := '6520757365642E22292C636F6E736F6C652E6572726F722874292C723D652C636F6E736F6C652E6572726F722872297D72657475726E20727D2C73706C6974537472696E673241727261793A66756E6374696F6E2865297B6966286E2E69734150455828';
wwv_flow_api.g_varchar2_table(203) := '292626617065782E7365727665722626617065782E7365727665722E6368756E6B2972657475726E20617065782E7365727665722E6368756E6B2865293B76617220742C723D5B5D3B696628652E6C656E6774683E386533297B666F7228723D5B5D2C74';
wwv_flow_api.g_varchar2_table(204) := '3D303B743C652E6C656E6774683B29722E7075736828652E73756273747228742C38653329292C742B3D3865333B72657475726E20727D72657475726E20722E707573682865292C727D7D3B72657475726E7B696E697469616C697A653A66756E637469';
wwv_flow_api.g_varchar2_table(205) := '6F6E28652C6F297B6E2E64656275672E696E666F286F293B76617220693D6F3B696628692E73616E6974697A654F7074696F6E733D6E2E6A736F6E53617665457874656E64287B414C4C4F5745445F415454523A5B226163636573736B6579222C22616C';
wwv_flow_api.g_varchar2_table(206) := '69676E222C22616C74222C22616C77617973222C226175746F636F6D706C657465222C226175746F706C6179222C22626F72646572222C2263656C6C70616464696E67222C2263656C6C73706163696E67222C2263686172736574222C22636C61737322';
wwv_flow_api.g_varchar2_table(207) := '2C22646972222C22686569676874222C2268726566222C226964222C226C616E67222C226E616D65222C2272656C222C227265717569726564222C22737263222C227374796C65222C2273756D6D617279222C22746162696E646578222C227461726765';
wwv_flow_api.g_varchar2_table(208) := '74222C227469746C65222C2274797065222C2276616C7565222C227769647468225D2C414C4C4F5745445F544147533A5B2261222C2261646472657373222C2262222C22626C6F636B71756F7465222C226272222C2263617074696F6E222C22636F6465';
wwv_flow_api.g_varchar2_table(209) := '222C226464222C22646976222C22646C222C226474222C22656D222C2266696763617074696F6E222C22666967757265222C226831222C226832222C226833222C226834222C226835222C226836222C226872222C2269222C22696D67222C226C616265';
wwv_flow_api.g_varchar2_table(210) := '6C222C226C69222C226E6C222C226F6C222C2270222C22707265222C2273222C227370616E222C22737472696B65222C227374726F6E67222C22737562222C22737570222C227461626C65222C2274626F6479222C227464222C227468222C2274686561';
wwv_flow_api.g_varchar2_table(211) := '64222C227472222C2275222C22756C225D7D2C6F2E73616E6974697A654F7074696F6E73292C224E223D3D692E73616E6974697A653F692E73616E6974697A653D21313A692E73616E6974697A653D21302C224E223D3D692E65736361706548544D4C3F';
wwv_flow_api.g_varchar2_table(212) := '692E65736361706548544D4C3D21313A692E65736361706548544D4C3D21302C224E223D3D692E756E45736361706548544D4C3F692E756E45736361706548544D4C3D21313A692E756E45736361706548544D4C3D21302C2259223D3D692E73686F774C';
wwv_flow_api.g_varchar2_table(213) := '6F616465723F692E73686F774C6F616465723D21303A692E73686F774C6F616465723D21312C2259223D3D692E75736555525445496D674C6F616465723F692E75736555525445496D674C6F616465723D21303A692E75736555525445496D674C6F6164';
wwv_flow_api.g_varchar2_table(214) := '65723D21312C692E616666456C656D656E74733D5B5D2C652E6166666563746564456C656D656E74732626242E6561636828652E6166666563746564456C656D656E74732C66756E6374696F6E28652C74297B76617220723D242874292E617474722822';
wwv_flow_api.g_varchar2_table(215) := '696422293B722626692E616666456C656D656E74732E70757368282223222B72297D292C692E73686F774C6F616465722626242E6561636828692E616666456C656D656E74732C66756E6374696F6E28652C74297B6E2E6C6F616465722E737461727428';
wwv_flow_api.g_varchar2_table(216) := '74297D292C225052494E545F434C4F42223D3D692E66756E6374696F6E54797065297B76617220613D692E6974656D73325375626D69743B617065782E7365727665722E706C7567696E28692E616A617849442C7B7830313A6F2E66756E6374696F6E54';
wwv_flow_api.g_varchar2_table(217) := '7970652C706167654974656D733A617D2C7B737563636573733A66756E6374696F6E2865297B7228652C69297D2C6572726F723A66756E6374696F6E2865297B6E2E64656275672E6572726F7228652E726573706F6E736554657874297D2C6461746154';
wwv_flow_api.g_varchar2_table(218) := '7970653A226A736F6E227D297D656C73652166756E6374696F6E28652C72297B766172206F3D6E2E6765744974656D56616C756528652E6974656D53746F726573434C4F42292C693D652E6974656D73325375626D69742C613D6E2E6765744974656D56';
wwv_flow_api.g_varchar2_table(219) := '616C756528652E636F6C6C656374696F6E4E616D654974656D293B652E756E45736361706548544D4C2626286F3D6E2E756E45736361706548544D4C286F29292C652E73616E6974697A652626286F3D74286F2C6529293B766172206C3D6E2E73706C69';
wwv_flow_api.g_varchar2_table(220) := '74537472696E67324172726179286F293B617065782E7365727665722E706C7567696E28652E616A617849442C7B7830313A652E66756E6374696F6E547970652C7830323A612C6630313A6C2C706167654974656D733A697D2C7B64617461547970653A';
wwv_flow_api.g_varchar2_table(221) := '2274657874222C737563636573733A66756E6374696F6E2874297B242E6561636828652E616666456C656D656E74732C66756E6374696F6E28652C74297B6E2E6C6F616465722E73746F702874292C617065782E6576656E742E7472696767657228742C';
wwv_flow_api.g_varchar2_table(222) := '22636C6F6275706C6F6164636F6D706C65746522297D292C6E2E64656275672E696E666F282255706C6F6164207375636365737366756C2E22297D2C6572726F723A66756E6374696F6E28742C722C6F297B242E6561636828652E616666456C656D656E';
wwv_flow_api.g_varchar2_table(223) := '74732C66756E6374696F6E28652C74297B6E2E6C6F616465722E73746F702874297D292C6E2E64656275672E696E666F282255706C6F6164206572726F722E22292C6E2E64656275672E6572726F722874292C6E2E64656275672E6572726F722872292C';
wwv_flow_api.g_varchar2_table(224) := '6E2E64656275672E6572726F72286F297D7D297D2869297D7D7D28293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(65252134902550163127)
,p_plugin_id=>wwv_flow_api.id(64887869323691230468)
,p_file_name=>'clobload.pkgd.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
