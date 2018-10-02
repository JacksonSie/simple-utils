#!/usr/bin/env bash
#經證實，無法在一個transaction中塞那麼大量的DML，因此無法利用一個 query 實作，必須要把大的 query 拆 分成各區。
#客戶更新 sample

export table_name=socmgr.events_sample
[[ "$return_deleted" == "1" && "$rescue_mode" == "1" ]] && bypass_truncate=-- || bypass_truncate=''
echo -e "----[sample monthly report proecssing start] `date` [sample monthly report proecssing start]----"
sqlplus -s $USERNAME/$usrpass@$ORACLE_SID << exit
alter session set nls_date_format = 'yyyymmdd hh24:mi:ss';
$bypass_truncate TRUNCATE TABLE events_sample;
COMMIT;
declare
    var_dateStart esecdba.events.evt_time%type := trunc(sysdate - interval '1 'month ,'MM');
    var_dateEnd esecdba.events.evt_time%type := trunc(sysdate ,'MM') - 1/86400;
    --var_dateStart esecdba.events.evt_time%type :=to_date('20170701000000' , 'yyyymmddhh24miss');
    --var_dateEnd esecdba.events.evt_time%type := to_date('20170731235959' , 'yyyymmddhh24miss');
    TYPE t_sample IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    sample t_sample;
begin
    sample(1) := 106700; --sampleDataCategory
    sample(2) := 106701; --sampleDataCategory
    sample(3) := 106800; --sampleDataCategory
    sample(4) := 106803; --sampleDataCategory
    FOR sample_index IN 1..sample.COUNT LOOP
        INSERT INTO events_sample
        SELECT DISTINCT to_char(events.evt_time + 8 / 24, 'yyyymmdd') AS data_day
            ,events.cust_id
            ,events.sev
            ,events.evt
            ,conver_nip(events.sip) source_ip
            ,events.shn
            ,events.sp_int
            ,conver_nip(events.dip) dest_ip
            ,events.dhn
            ,evt_prtcl.prtcl_name AS protocol
            ,events.dp_int
            ,events.fn
            ,events.rt1
            ,events.rv31
            ,evt_agent.device_ctgry
            ,events.rv24
            ,events.rv46
            ,events.rv145
            ,events.cv21
            ,events.cv22
            ,events.cv65 AS block_type
            ,events.msg
            ,events.evt_id
            ,evt_agent.pn
            ,evt_agent.sn
            ,events.cv66
            ,events.sun
            ,events.dun
            ,events.rv45
            ,EVT_XDAS_TXNMY.XDAS_OUTCOME_NAME
            ,events.TRGT_TRUST_NAME
        FROM esecdba.events
        left join EVT_XDAS_TXNMY on (EVT_XDAS_TXNMY.XDAS_TXNMY_ID = events.rid02)
            ,esecdba.evt_agent
            ,esecdba.evt_prtcl
        WHERE events.agent_id = evt_agent.agent_id
            AND events.prtcl_id = evt_prtcl.prtcl_id
            AND events.cust_id = sample(sample_index)
            AND events.evt_time >= var_dateStart - 8 / 24
            AND events.evt_time <= var_dateEnd - 8 / 24
            AND NOT (
                events.CUST_ID = 106800
                AND events.RV31 IN ('Sentinel Link')
                );
        COMMIT;
    end loop;
--https://www.paloaltonetworks.com/documentation/70/pan-os/pan-os/monitoring/syslog-field-descriptions
    INSERT INTO events_sample
    SELECT to_char(events.evt_time + 8 / 24, 'yyyymmdd') AS data_day
        ,events.cust_id
        ,events.sev
        ,events.evt
        ,conver_nip(events.sip) source_ip
        ,events.shn
        ,events.sp_int
        ,conver_nip(events.dip) dest_ip
        ,events.dhn
        ,evt_prtcl.prtcl_name AS protocol
        ,events.dp_int
        ,events.fn
        ,events.rt1
        ,events.rv31
        ,'IPS/FW' as device_ctgry
        ,events.rv24
        ,events.rv46
        ,events.rv145
        ,events.cv21
        ,events.cv22
        ,'BLOCK(IPS/FW)' AS block_type
        ,events.msg
        ,events.evt_id
        ,evt_agent.pn
        ,evt_agent.sn
        ,events.cv66
        ,events.sun
        ,events.dun
        ,events.rv45
        ,EVT_XDAS_TXNMY.XDAS_OUTCOME_NAME
        ,events.TRGT_TRUST_NAME
    FROM esecdba.events
    left join EVT_XDAS_TXNMY on (EVT_XDAS_TXNMY.XDAS_TXNMY_ID = events.rid02)
        ,esecdba.evt_agent
        ,esecdba.evt_prtcl
    WHERE events.agent_id = evt_agent.agent_id
        AND events.prtcl_id = evt_prtcl.prtcl_id
        AND events.cust_id IN (106800)
        AND events.rv31 IN ('Sentinel Link')
        AND (
            events.ei LIKE '%threat detected and session remains, but drops allpackets%'
            OR events.ei LIKE '%flood detection mechanism activated and deny traffic based on configuration%'
            OR events.ei LIKE '%threat detected and associated session was dropped%'
            OR events.ei LIKE '%threat detected and a TCP RST is sent to the client%'
            OR events.ei LIKE '%threat detected and a TCP RST is sent to the server%'
            OR events.ei LIKE '%threat detected and a TCP RST is sent to both the client and the server%'
            OR events.ei LIKE '%URL request was blocked because it matched a URL category that was set to be blocked%'
            )
        AND events.evt_time >= var_dateStart - 8 / 24
        AND events.evt_time <= var_dateEnd - 8 / 24;
    COMMIT;
    ----------------------------
    UPDATE events_sample a
    SET A.BLOCK_TYPE = 'BLOCK(AD)'
    WHERE A.CUST_ID = 106701
        AND device_ctgry = 'OS' and xdas_outcome_name IN (
            'XDAS_OUT_INVALID_USER_CREDENTIALS'
            ,'XDAS_OUT_FAILURE'
            ,'XDAS_OUT_DISABLED'
            );
    commit;
    UPDATE SOCMGR.events_sample
    SET dhn = nvl(
            trim(substr(regexp_substr(msg, 'suser=(.*?) |$'), 7, 255))
            ,substr(regexp_substr(msg, 'dhost=(.*?) |$'), 7, 255)
        )
        ,rt1 = nvl(
            trim(substr(regexp_substr(msg, 'cs4=(.*?) '), 5, 255)) ,
            nvl(
                regexp_replace(trim(substr(regexp_substr(msg, '已刪除: {0,1}(.*?)\\'), 6, 255)),'\\','')
                ,nvl (
                    regexp_replace(trim(substr(regexp_substr(msg, '已被隔離:\s{0,1}(.*?)\\'), 7, 255)),'\\','')
                    ,nvl(
                        regexp_replace(trim(substr(regexp_substr(msg, '已解毒:\s{0,1}(.*?)\\'), 6, 255)),'\\','')
                        ,regexp_replace(trim(substr(regexp_substr(msg, '偵測到的威脅:\s{0,1}(.*?)\\'), 9, 255)),'\\','')
                    )
                )
            )
        )
        ,dest_ip = nvl(
            trim(substr(regexp_substr(msg, 'src=(.*?) '), 5, 255))
            ,trim(substr(regexp_substr(msg, 'dst=(.*?) '), 5, 255))
        )
    WHERE cust_id IN (
            106700
            ,106803
            ,106800
            )
        AND (
            msg LIKE '% suser=%'
            or msg LIKE '% dhost=%'
            OR msg LIKE '% cs4Label=VirusName %'
            OR msg LIKE '% src=%'
            or msg LIKE '% dst=%'
            )
        AND (
            dhn IS NULL
            OR rt1 IS NULL
            OR dest_ip IS NULL
            )
        AND device_ctgry = 'AV';
    COMMIT;
    UPDATE SOCMGR.events_sample
    SET block_type = (
            CASE
                WHEN block_type = 'BLOCK(AV)'
                    THEN 'BLOCK(AV_WEB)'
                ELSE block_type
                END
            )
        ,device_ctgry = 'AV_WEB'
    WHERE cust_id IN (
            106700
            ,106803
            ,106800
            )
        AND lower(msg) LIKE '%http%'
        AND device_ctgry = 'AV';
    COMMIT;
    UPDATE SOCMGR.events_sample
    SET device_ctgry = 'AV_WEB'
    WHERE dhn IS NULL
        AND dest_ip IS NULL
        AND cust_id IN (
            106700
            ,106803
            ,106800
            )
        AND device_ctgry = 'AV';
    UPDATE events_sample a
    SET A.BLOCK_TYPE = 'BLOCK(AV)'
    WHERE cust_id in (106803 , 106700 , 106800)
        AND device_ctgry = 'AV'
        AND block_type IS NULL
        AND msg LIKE '%清除%';
    COMMIT;
    UPDATE SOCMGR.events_sample
    SET device_ctgry = 'AV_WEB'
    WHERE msg = '________-____-____-____-____________';
        COMMIT;
    ----------------------------
    FOR sample_index IN 1..sample.COUNT LOOP
        DELETE
        FROM block_event
        WHERE cust_id = sample(sample_index)
            AND event_date BETWEEN TO_CHAR(var_dateStart, 'yyyymmdd')
                AND to_char(var_dateEnd, 'yyyymmdd') + 1;
        COMMIT;
        INSERT INTO cust_block_event (
            cust_id
            ,block_type
            ,block_count
            ,event_date
            )
        SELECT b.cust_id AS cust_id
            ,b.block_type AS block_type
            ,CASE
                WHEN a.block_count IS NULL
                    THEN 0
                ELSE A.BLOCK_COUNT
                END AS block_count
            ,b.date_iter AS event_date
        FROM (
            SELECT cust_id
                ,data_day
                ,block_type
                ,count(1) block_count
            FROM socmgr.events_sample
            WHERE block_type IS NOT NULL
                AND cust_id = sample(sample_index)
            GROUP BY cust_id
                ,data_day
                ,block_type
            ) a
        RIGHT JOIN (
            SELECT DISTINCT cust_id
                ,block_type
                ,0 AS block_count
                ,date_iter
            FROM socmgr.events_sample
            CROSS JOIN (
                SELECT to_char(var_dateStart, 'yyyymmdd')+LEVEL-1 AS date_iter
                FROM dual connect BY LEVEL <= 32
                )
            WHERE block_type IS NOT NULL
                AND cust_id = sample(sample_index)
            ) b ON (
                a.cust_id = b.cust_id
                AND a.data_day = b.date_iter
                AND a.block_type = b.block_type
                )
        WHERE date_iter BETWEEN TO_CHAR(var_dateStart, 'yyyymmdd')
                AND to_char(var_dateEnd, 'yyyymmdd');
        COMMIT;
    end loop;
    INSERT INTO cust_block_event
    SELECT 106701
        ,to_char(trunc(sysdate - interval '1' month, 'dd'), 'yyyymmdd')
        ,'BLOCK(PROXY)'
        ,0
    FROM dual;
    COMMIT;
    INSERT INTO cust_block_event
    SELECT 106803
        ,to_char(trunc(sysdate - interval '1' month, 'dd'), 'yyyymmdd')
        ,'BLOCK(IPS)'
        ,0
    FROM dual;
    COMMIT;
    DELETE
    FROM cust_block_event
    WHERE BLOCK_TYPE = 'BLOCK(AV_WEB)'
        AND cust_id IN (
            106700
            ,106800
            ,106803
            )
        AND event_date BETWEEN TO_CHAR(var_dateStart, 'yyyymmdd')
            AND to_char(var_dateEnd, 'yyyymmdd') + 1;
    COMMIT;
    ----------------------------
    FOR sample_index IN 1..sample.COUNT LOOP
        DELETE
        FROM banned
        WHERE data_day BETWEEN var_dateStart
                AND var_dateEnd + 1
            AND cust_id = sample(sample_index);
        COMMIT;
        INSERT INTO banned (
            data_day
            ,cust_id
            ,evt
            ,source_ip
            ,sp_int
            ,dest_ip
            ,dp_int
            ,protocol
            ,device_ctgry
            ,block_type
            ,url_ip_type
            )
        SELECT to_date(events_sample.data_day, 'yyyymmdd')
            ,events_sample.cust_id
            ,substr(events_sample.evt,1,50)
            ,events_sample.source_ip
            ,events_sample.sp_int
            ,events_sample.dest_ip
            ,events_sample.dp_int
            ,events_sample.protocol
            ,events_sample.device_ctgry
            ,events_sample.block_type
            ,CASE
                WHEN peer_banned.black_sip = events_sample.source_ip
                    THEN 'SRC_IP'
                WHEN peer_banned.black_sip = events_sample.dest_ip
                    THEN 'DST_IP'
                END AS url_ip_type
        FROM socmgr.events_sample
            ,peer_banned
        WHERE (
                peer_banned.black_sip = events_sample.source_ip
                OR peer_banned.black_sip = events_sample.dest_ip
                )
            AND events_sample.cust_id = sample(sample_index);
        COMMIT;
        INSERT INTO banned (
            data_day
            ,cust_id
            ,evt
            ,source_ip
            ,sp_int
            ,dest_ip
            ,dp_int
            ,protocol
            ,device_ctgry
            ,block_type
            ,url_ip_type
            ,URL_OR_IP
            )
        SELECT events_sample.data_day
            ,events_sample.cust_id
            ,events_sample.evt
            ,events_sample.source_ip
            ,events_sample.sp_int
            ,events_sample.dest_ip
            ,events_sample.dp_int
            ,events_sample.protocol
            ,events_sample.device_ctgry
            ,events_sample.block_type
            ,CASE
                WHEN events_sample.shn LIKE '%' || peer_banned.black_dn || '%'
                    THEN 'SRC_DN'
                WHEN events_sample.dhn LIKE '%' || peer_banned.black_dn || '%'
                    THEN 'DST_DN'
                END AS url_ip_type
            ,peer_banned.black_dn
        FROM socmgr.events_sample
            ,peer_banned
        WHERE (
                events_sample.shn LIKE '%' || peer_banned.black_dn || '%'
                OR events_sample.dhn LIKE '%' || peer_banned.black_dn || '%'
                )
            AND events_sample.cust_id = sample(sample_index);
        COMMIT;
    end loop;
end;
/
exit
echo -e "----[sample monthly report proecssing end] `date` [sample monthly report proecssing end]----\n"