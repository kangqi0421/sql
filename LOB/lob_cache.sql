alter table ARL_CRL_TBL modify lob (CRL_DATA) (cache);
alter table ARL_CRL_TBL modify lob (ARL_DATA) (cache);

-- result cache --
SELECT /*+ result_cache */ TO_CHAR(CRL_ARL_NUM), CRL_DATA, ARL_DATA FROM CSESC1.ARL_CRL_TBL ORDER BY CRL_ARL_NUM DESC;

-- CAEPB
SELECT TO_CHAR(CRL_ARL_NUM), CRL_DATA, ARL_DATA FROM CSESC2.ARL_CRL_TBL ORDER BY CRL_ARL_NUM DESC

CSESC2.ARL_CRL_TBL.CRL_DATA -> SYS_LOB0000018704C00005$$
CSESC2.ARL_CRL_TBL.ARL_DATA -> SYS_LOB0000018704C00006$$