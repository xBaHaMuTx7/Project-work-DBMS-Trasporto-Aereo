/* --------------------------------------------------------------------------
 * ALFIO CASTIGLIONE - Trasporto Aereo
 * --------------------------------------------------------------------------
 * QUERIES SQL
 * --------------------------------------------------------------------------
 * Ambiente: Oracle Database XE21 (Da eseguire in SQL Developer)
*/ --------------------------------------------------------------------------
 
 
/* --------------------------------------------------------------------------
     1. Ricerca di Biglietti Disponibili.
        Calcola i posti ancora disponibili su tutti i voli attivi 
        in una data futura restituendo anche la capacitá dell'aereomobile,
        i posti venduti e quelli disponibili.
*/ --------------------------------------------------------------------------

    SELECT
        V.DataVolo AS Data_Volo, 
        T.CodiceTratta, 
        A.CapacitaTotale,
        COUNT(DBV.IDBigliettoFK) AS Posti_Venduti,
        (A.CapacitaTotale - COUNT(DBV.IDBigliettoFK)) AS Posti_Disponibili
    FROM VOLI V
        JOIN TRATTE T 
            ON V.CodiceTrattaFK = T.CodiceTratta
        JOIN AEROMOBILI A 
            ON V.MatricolaAeromobileFK = A.Matricola
        LEFT JOIN DETTAGLI_BIGLIETTI_VOLI DBV 
            ON V.IDVolo = DBV.IDVoloFK
    WHERE V.STATO = 'PROGRAMMATO'
      AND V.DataVolo >= CURRENT_DATE
    GROUP BY
        V.IDVolo, V.DataVolo, T.CodiceTratta, A.CapacitaTotale
    HAVING
        (A.CapacitaTotale - COUNT(DBV.IDBigliettoFK)) > 0
    ORDER BY
        V.DataVolo, T.CodiceTratta;
