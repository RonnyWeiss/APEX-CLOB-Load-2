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
 p_id=>wwv_flow_api.id(32064896570320984361)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'APEX.CLOB.LOAD.2'
,p_display_name=>'APEX CLOB Load 2'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
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
'    VR_COLLECTION_NAME   VARCHAR2(32767) := APEX_APPLICATION.G_X01;',
'BEGIN',
'    IF P_DYNAMIC_ACTION.ATTRIBUTE_04 = ''PRINT_CLOB'' THEN',
'/* undocumented function of APEX for get all bindings */',
'        VR_BIND_NAMES   := WWV_FLOW_UTILITIES.GET_BINDS(VR_SQL);',
'        VR_CUR          := SQL_TO_SYS_REFCURSOR(',
'            RTRIM(',
'                VR_SQL,',
'                '';''',
'            ),',
'            VR_BIND_NAMES',
'        );',
'',
'/* create json */',
'        APEX_JSON.OPEN_OBJECT;',
'        APEX_JSON.WRITE(',
'            ''row'',',
'            VR_CUR',
'        );',
'        APEX_JSON.CLOSE_OBJECT;',
'',
'/* does not support cursor */',
'--APEX_UTIL.JSON_FROM_SQL( SQLQ   => P_REGION.SOURCE );',
'    ELSE',
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
'',
'    END IF;',
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
'BEGIN',
'    APEX_JAVASCRIPT.ADD_LIBRARY(',
'        P_NAME        => ''script.min'',',
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
'        ''itemStoresCLOB'',',
'        VR_ITEMS_STORE_CLOB',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''escapeHTML'',',
'        VR_ESCAPE_HTML',
'    ) ||',
'    APEX_JAVASCRIPT.ADD_ATTRIBUTE(',
'        ''collectionNameItem'',',
'        VR_COLLECTION_NAME',
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
'When you want to get content of collection when submit page. Call the Upload with Dynamic Action "Before PAge Submit".'))
,p_version_identifier=>'1.0.1'
,p_about_url=>'https://github.com/RonnyWeiss/APEX-CLOB-Load-2'
,p_files_version=>60
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(32065105063212996720)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'SQL Source'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
'    /* Element type dom - for jQuery selector e.g. body or #region-id, item - for item name e.g. P1_MY_ITEM, richtext - for item name when item is richtexteditor */',
'    ''dom'' AS ELEMENT_TYPE,',
'    /* jQuery selector or item name */',
'    ''body'' AS ELEMENT_SELECTOR,',
'    /* CLOB value */',
'    TO_CLOB(''Hello World'') AS CLOB_VALUE',
'FROM',
'    DUAL'))
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(32066138790488082886)
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
'    ''richtext'' AS ELEMENT_TYPE,',
'    ''P1_ITEM_RICH_TEXT'' AS ELEMENT_SELECTOR,',
'    TO_CLOB(''Hello World'') AS CLOB_VALUE',
'FROM',
'    DUAL',
'UNION ALL',
'SELECT',
'    ''dom'' AS ELEMENT_TYPE,',
'    ''body'' AS ELEMENT_SELECTOR,',
'    TO_CLOB(''Hello World'') AS CLOB_VALUE',
'FROM',
'    DUAL',
'</pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Since this plug-in can load multiple elements once, the element, the type and the CLOB must be specified in the SQL statement. Each line thus loads one element with CLOB.',
'',
'An example:',
'<pre>',
'SELECT',
'    /* Element type dom - for jQuery selector e.g. body or #region-id, item - for item name e.g. P1_MY_ITEM, richtext - for item name when item is richtexteditor */',
'    ''dom'' AS ELEMENT_TYPE,',
'    /* jQuery selector or item name */',
'    ''body'' AS ELEMENT_SELECTOR,',
'    /* CLOB value */',
'    TO_CLOB(''Hello World'') AS CLOB_VALUE',
'FROM',
'    DUAL',
'</pre>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(32065109186146998847)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
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
 p_id=>wwv_flow_api.id(32065134692071002020)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>110
,p_prompt=>'Escape special Characters'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'Select if special characters should be escaped.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(32066138790488082886)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
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
 p_id=>wwv_flow_api.id(32066139509433083932)
,p_plugin_attribute_id=>wwv_flow_api.id(32066138790488082886)
,p_display_sequence=>10
,p_display_value=>'Print CLOBs'
,p_return_value=>'PRINT_CLOB'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(32066111270189083251)
,p_plugin_attribute_id=>wwv_flow_api.id(32066138790488082886)
,p_display_sequence=>20
,p_display_value=>'Upload CLOB'
,p_return_value=>'UPLOAD_CLOB'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(32084332245578574847)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>120
,p_prompt=>'Show Loader Icon'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'If selected then loader icon is shown on affected element. The Dynamic Action Events of this plugin is also fired on the affcted element.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(32269636873864322104)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>20
,p_prompt=>'Upload to'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'COLLECTION'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(32066138790488082886)
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
 p_id=>wwv_flow_api.id(32270103093580323297)
,p_plugin_attribute_id=>wwv_flow_api.id(32269636873864322104)
,p_display_sequence=>10
,p_display_value=>'Collection'
,p_return_value=>'COLLECTION'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(32270104619465324847)
,p_plugin_attribute_id=>wwv_flow_api.id(32269636873864322104)
,p_display_sequence=>20
,p_display_value=>'Execute PL/SQL'
,p_return_value=>'PLSQL'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(32270138183890329224)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
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
,p_depending_on_attribute_id=>wwv_flow_api.id(32269636873864322104)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PLSQL'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'You can execute dynamic PL/SQL when upload a CLOB.',
'Important is that you use the binding :CLOB',
'for this biding the uploaded CLOB is set.',
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
 p_id=>wwv_flow_api.id(32270144140172332791)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Item stores Collection Name'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(32269636873864322104)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'COLLECTION'
,p_help_text=>'Select an Item that stores the collection name.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(32275316427745514841)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Item stores CLOB Value'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(32066138790488082886)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'UPLOAD_CLOB'
,p_help_text=>'Choose the item from which you want to upload the CLOB.'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(32339403363424848363)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
,p_name=>'clobrendercomplete'
,p_display_name=>'CLOB Render Complete'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(32339403043082848361)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
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
 p_id=>wwv_flow_api.id(32343785125706179981)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
,p_file_name=>'LICENSE'
,p_mime_type=>'application/octet-stream'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '76617220636C6F624C6F61643D66756E6374696F6E28297B2275736520737472696374223B66756E6374696F6E207228652C722C6F297B7472797B742E64656275672E696E666F2865292C652E726F772626652E726F772E6C656E6774683E302626242E';
wwv_flow_api.g_varchar2_table(2) := '6561636828652E726F772C66756E6374696F6E28652C6F297B6F2E454C454D454E545F53454C4543544F5226266F2E434C4F425F56414C55452626286F2E454C454D454E545F545950453F22646F6D223D3D6F2E454C454D454E545F545950453F66756E';
wwv_flow_api.g_varchar2_table(3) := '6374696F6E28652C722C6F297B653F28242865292E656D70747928292C6F2E65736361706548544D4C3F242865292E746578742872293A242865292E68746D6C287229293A742E64656275672E6572726F7228224E6F20454C454D454E545F53454C4543';
wwv_flow_api.g_varchar2_table(4) := '544F522073657420696E2053514C20666F7220434C4F422052656E64657222297D286F2E454C454D454E545F53454C4543544F522C6F2E434C4F425F56414C55452C72293A226974656D223D3D6F2E454C454D454E545F545950453F66756E6374696F6E';
wwv_flow_api.g_varchar2_table(5) := '28652C722C6F297B76617220613B653F28613D6F2E65736361706548544D4C3F742E65736361706548544D4C2872293A722C742E7365744974656D56616C756528652C6129293A742E64656275672E6572726F7228224E6F20454C454D454E545F53454C';
wwv_flow_api.g_varchar2_table(6) := '4543544F522073657420696E2053514C20666F7220434C4F422052656E64657222297D286F2E454C454D454E545F53454C4543544F522C6F2E434C4F425F56414C55452C72293A227269636874657874223D3D6F2E454C454D454E545F545950453F6675';
wwv_flow_api.g_varchar2_table(7) := '6E6374696F6E28652C722C6F297B76617220612C6E3D21313B653F28613D6F2E65736361706548544D4C3F742E65736361706548544D4C2872293A722C434B454449544F522E6F6E2822696E7374616E63655265616479222C66756E6374696F6E287229';
wwv_flow_api.g_varchar2_table(8) := '7B742E64656275672E696E666F2822434B454449544F5220696E7374616E6365526561647920666972656422292C742E7365744974656D56616C756528652C61292C6E3D21307D292C73657454696D656F75742866756E6374696F6E28297B2130213D3D';
wwv_flow_api.g_varchar2_table(9) := '6E262628742E64656275672E696E666F28224E6F20496E7374616E6365205265616479206576656E742066726F6D20434B454449544F5222292C742E7365744974656D56616C756528652C6129297D2C37303029293A742E64656275672E6572726F7228';
wwv_flow_api.g_varchar2_table(10) := '224E6F20454C454D454E545F53454C4543544F522073657420696E2053514C20666F7220434C4F422052656E64657222297D286F2E454C454D454E545F53454C4543544F522C6F2E434C4F425F56414C55452C72293A742E64656275672E6572726F7228';
wwv_flow_api.g_varchar2_table(11) := '22454C454D454E545F54595045206D7573742062653A20646F6D2C206974656D206F7220726963687465787420616E64206E6F7420222B6F2E454C454D454E545F54595045293A742E64656275672E6572726F722822454C454D454E545F545950452069';
wwv_flow_api.g_varchar2_table(12) := '73206E756C6C20696E2053514C20666F7220434C4F422052656E6465722229297D292C2259223D3D722E73686F774C6F6164657226266F2E6166666563746564456C656D656E74732626242E65616368286F2E6166666563746564456C656D656E74732C';
wwv_flow_api.g_varchar2_table(13) := '66756E6374696F6E28652C72297B766172206F3D242872292E617474722822696422293B6F2626742E6C6F616465722E73746F70282223222B6F292C242872292E747269676765722822636C6F6272656E646572636F6D706C65746522297D297D636174';
wwv_flow_api.g_varchar2_table(14) := '63682865297B742E64656275672E6572726F7228224572726F72207768696C652072656E64657220434C4F4222292C742E64656275672E6572726F722865297D7D76617220743D7B76657273696F6E3A22312E302E35222C6973415045583A66756E6374';
wwv_flow_api.g_varchar2_table(15) := '696F6E28297B72657475726E22756E646566696E656422213D747970656F6620617065787D2C64656275673A7B696E666F3A66756E6374696F6E2865297B742E69734150455828292626617065782E64656275672E696E666F2865297D2C6572726F723A';
wwv_flow_api.g_varchar2_table(16) := '66756E6374696F6E2865297B742E69734150455828293F617065782E64656275672E6572726F722865293A636F6E736F6C652E6572726F722865297D7D2C65736361706548544D4C3A66756E6374696F6E2865297B6966286E756C6C3D3D3D6529726574';
wwv_flow_api.g_varchar2_table(17) := '75726E206E756C6C3B696628766F69642030213D3D65297B696628226F626A656374223D3D747970656F662065297472797B653D4A534F4E2E737472696E676966792865297D63617463682865297B7D72657475726E20742E69734150455828293F6170';
wwv_flow_api.g_varchar2_table(18) := '65782E7574696C2E65736361706548544D4C28537472696E67286529293A28653D537472696E67286529292E7265706C616365282F262F672C2226616D703B22292E7265706C616365282F3C2F672C22266C743B22292E7265706C616365282F3E2F672C';
wwv_flow_api.g_varchar2_table(19) := '222667743B22292E7265706C616365282F222F672C222671756F743B22292E7265706C616365282F272F672C2226237832373B22292E7265706C616365282F5C2F2F672C2226237832463B22297D7D2C6C6F616465723A7B73746172743A66756E637469';
wwv_flow_api.g_varchar2_table(20) := '6F6E2865297B696628742E697341504558282929617065782E7574696C2E73686F775370696E6E65722824286529293B656C73657B76617220723D2428223C7370616E3E3C2F7370616E3E22293B722E6174747228226964222C226C6F61646572222B65';
wwv_flow_api.g_varchar2_table(21) := '292C722E616464436C617373282263742D6C6F6164657222293B766172206F3D2428223C693E3C2F693E22293B6F2E616464436C617373282266612066612D726566726573682066612D32782066612D616E696D2D7370696E22292C6F2E637373282262';
wwv_flow_api.g_varchar2_table(22) := '61636B67726F756E64222C2272676261283132312C3132312C3132312C302E362922292C6F2E6373732822626F726465722D726164697573222C223130302522292C6F2E637373282270616464696E67222C223135707822292C6F2E6373732822636F6C';
wwv_flow_api.g_varchar2_table(23) := '6F72222C22776869746522292C722E617070656E64286F292C242865292E617070656E642872297D7D2C73746F703A66756E6374696F6E2865297B2428652B22203E202E752D50726F63657373696E6722292E72656D6F766528292C2428652B22203E20';
wwv_flow_api.g_varchar2_table(24) := '2E63742D6C6F6164657222292E72656D6F766528297D7D2C7365744974656D56616C75653A66756E6374696F6E28722C6F297B742E69734150455828293F617065782E6974656D287229262630213D617065782E6974656D2872292E6E6F64653F617065';
wwv_flow_api.g_varchar2_table(25) := '782E6974656D2872292E73657456616C7565286F293A636F6E736F6C652E6572726F722822506C656173652063686F6F7365206120736574206974656D2E2042656361757365207468652076616C75652028222B6F2B22292063616E206E6F7420626520';
wwv_flow_api.g_varchar2_table(26) := '736574206F6E206974656D2028222B722B222922293A636F6E736F6C652E6572726F7228224572726F72207768696C652074727920746F2063616C6C20617065782E6974656D222B65297D7D3B72657475726E7B696E697469616C697A653A66756E6374';
wwv_flow_api.g_varchar2_table(27) := '696F6E28652C6F297B742E64656275672E696E666F286F293B76617220613D6F3B696628224E223D3D612E65736361706548544D4C3F612E65736361706548544D4C3D21313A612E65736361706548544D4C3D21302C2259223D3D612E73686F774C6F61';
wwv_flow_api.g_varchar2_table(28) := '6465722626652E6166666563746564456C656D656E74732626242E6561636828652E6166666563746564456C656D656E74732C66756E6374696F6E28652C72297B766172206F3D242872292E617474722822696422293B6F2626742E6C6F616465722E73';
wwv_flow_api.g_varchar2_table(29) := '74617274282223222B6F297D292C225052494E545F434C4F42223D3D612E66756E6374696F6E54797065297B766172206E3D612E6974656D73325375626D69743B617065782E7365727665722E706C7567696E28612E616A617849442C7B706167654974';
wwv_flow_api.g_varchar2_table(30) := '656D733A6E7D2C7B737563636573733A66756E6374696F6E2874297B7228742C612C65297D2C6572726F723A66756E6374696F6E2865297B742E64656275672E6572726F7228652E726573706F6E736554657874297D2C64617461547970653A226A736F';
wwv_flow_api.g_varchar2_table(31) := '6E227D297D656C73652166756E6374696F6E28652C72297B766172206F3D617065782E6974656D28652E6974656D53746F726573434C4F42292E67657456616C756528292C613D617065782E7365727665722E6368756E6B286F292C6E3D617065782E69';
wwv_flow_api.g_varchar2_table(32) := '74656D28652E636F6C6C656374696F6E4E616D654974656D292E67657456616C756528292C693D652E6974656D73325375626D69743B617065782E7365727665722E706C7567696E28652E616A617849442C7B7830313A6E2C6630313A612C7061676549';
wwv_flow_api.g_varchar2_table(33) := '74656D733A697D2C7B64617461547970653A2274657874222C737563636573733A66756E6374696F6E286F297B722E6166666563746564456C656D656E74732626242E6561636828722E6166666563746564456C656D656E74732C66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(34) := '722C6F297B6966282259223D3D652E73686F774C6F61646572297B76617220613D24286F292E617474722822696422293B612626742E6C6F616465722E73746F70282223222B61297D24286F292E747269676765722822636C6F6275706C6F6164636F6D';
wwv_flow_api.g_varchar2_table(35) := '706C65746522297D292C742E64656275672E696E666F282255706C6F6164207375636365737366756C2E22297D2C6572726F723A66756E6374696F6E28652C722C6F297B742E64656275672E696E666F282255706C6F6164206572726F722E22292C742E';
wwv_flow_api.g_varchar2_table(36) := '64656275672E6572726F722865292C742E64656275672E6572726F722872292C742E64656275672E6572726F72286F297D7D297D28612C65297D7D7D28293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(32344865537892226157)
,p_plugin_id=>wwv_flow_api.id(32064896570320984361)
,p_file_name=>'script.min.js'
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
