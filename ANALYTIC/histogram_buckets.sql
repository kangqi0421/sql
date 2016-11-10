/* vytvoøení histogramu delky BLOBu nad REV.PRILOHA */

  SELECT   WIDTH_BUCKET (a, 0, MAX, buckets) * MAX / buckets "blocks",
         COUNT (*) cnt,
         ROUND (ratio_to_report (COUNT (*)) OVER () * 100) "pct [%]"
    FROM (SELECT NVL (CEIL (DBMS_LOB.getlength (OBSAH) / 8192), 0) a,           -- aktualni delka v bytech CLOBu
                 MAX (CEIL (DBMS_LOB.getlength (OBSAH) / 8192)) OVER () MAX,    -- max hodnota
                 CEIL (1 + 3.3 * LOG (10, COUNT (*) OVER ())) buckets           -- doporuceny hodnota bucketu
            FROM REV.PRILOHA)
GROUP BY   WIDTH_BUCKET (a, 0, MAX, buckets) * MAX / buckets
ORDER BY 1 ASC



with query as
(
select ceil(nvl(dbms_lob.getlength(MW_REQUEST), 0)) a -- tady davam alias pro sloupec do histogramu
  from ZC037_003.LOG_TRN SUBPARTITION (SP001)
)
  SELECT   WIDTH_BUCKET (a, 0, MAX, buckets) * MAX / buckets "blocks",
         COUNT (*) cnt,
         ROUND (ratio_to_report (COUNT (*)) OVER () * 100) "pct [%]"
    FROM (SELECT a,           				-- aktualni pocet znaku CLOBu
                 MAX (a) OVER () MAX,    		-- max hodnota
                 CEIL (1 + 3.3 * LOG (10, COUNT (*) OVER ())) buckets           -- doporuceny hodnota bucketu, neco kolem 10-ti
            FROM query)
GROUP BY   WIDTH_BUCKET (a, 0, MAX, buckets) * MAX / buckets
ORDER BY 1 ASC