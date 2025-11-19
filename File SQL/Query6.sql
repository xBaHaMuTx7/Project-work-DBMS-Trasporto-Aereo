/* --------------------------------------------------------------------------
 * ALFIO CASTIGLIONE - Trasporto Aereo
 * --------------------------------------------------------------------------
 * QUERIES SQL
 * --------------------------------------------------------------------------
 * Ambiente: Oracle Database XE21 (Da eseguire in SQL Developer)
*/ --------------------------------------------------------------------------
 
/* --------------------------------------------------------------------------    
     6. Questa query traccia i biglietti che includono 
     due o più segmenti di volo, calcolando la durata dello scalo in minuti.
*/ --------------------------------------------------------------------------

    WITH PercorsiVoli AS (
        SELECT
            DBV.IDBigliettoFK,
            V.IDVolo,
            T.CodiceTratta,
            ROW_NUMBER() OVER (PARTITION BY DBV.IDBigliettoFK ORDER BY V.DataVolo, V.OraPartenzaPrevista) AS Segmento,
            V.OraArrivoPrevista,
            LEAD(V.OraPartenzaPrevista, 1) OVER (PARTITION BY DBV.IDBigliettoFK ORDER BY V.DataVolo, V.OraPartenzaPrevista) AS ProssimaPartenza
        FROM DETTAGLI_BIGLIETTI_VOLI DBV
            JOIN VOLI V 
                ON DBV.IDVoloFK = V.IDVolo
            JOIN TRATTE T 
                ON V.CodiceTrattaFK = T.CodiceTratta
    )
    SELECT
        IDBigliettoFK,
        IDVolo AS Volo_Segmento,
        Segmento,
        OraArrivoPrevista,
        ProssimaPartenza,
        (EXTRACT(DAY FROM (ProssimaPartenza - OraArrivoPrevista)) * 24 * 60) +
        (EXTRACT(HOUR FROM (ProssimaPartenza - OraArrivoPrevista)) * 60) +
        (EXTRACT(MINUTE FROM (ProssimaPartenza - OraArrivoPrevista))) AS Durata_Scalo_Minuti
    FROM PercorsiVoli
    WHERE ProssimaPartenza IS NOT NULL;
