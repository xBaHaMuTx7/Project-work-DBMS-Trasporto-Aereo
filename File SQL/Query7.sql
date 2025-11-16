/* --------------------------------------------------------------------------
 * ALFIO CASTIGLIONE - Airline Ticketing System
 * --------------------------------------------------------------------------
 * QUERIES SQL
 * --------------------------------------------------------------------------
 * Ambiente: Oracle Database XE21 (Da eseguire in SQL Developer)
*/ --------------------------------------------------------------------------
 
/* --------------------------------------------------------------------------    
     7. Questa query traccia i ricavi dei vari voli, 
     calcolando i ricavi totali e ordinandoli in ordine decrescente.
*/ --------------------------------------------------------------------------
    WITH RicavoVolo AS (
        SELECT
            V.IDVolo,
            V.DataVolo,
            T.CodiceTratta,
            SUM(B.PrezzoFinale) AS RicavoTotale
        FROM VOLI V
            JOIN DETTAGLI_BIGLIETTI_VOLI DBV 
                ON V.IDVolo = DBV.IDVoloFK
            JOIN BIGLIETTI B 
                ON DBV.IDBigliettoFK = B.IDBiglietto
            JOIN TRATTE T 
                ON V.CodiceTrattaFK = T.CodiceTratta
        GROUP BY V.IDVolo, V.DataVolo, T.CodiceTratta
    )
    SELECT
        RV.IDVolo,
        RV.DataVolo,
        RV.CodiceTratta,
        RV.RicavoTotale,
        RANK() OVER (ORDER BY RV.RicavoTotale DESC) AS Rank_Ricavo_Assoluto,
        NTILE(4) OVER (ORDER BY RV.RicavoTotale DESC) AS Quartile_Rendimento
    FROM RicavoVolo RV
    ORDER BY Rank_Ricavo_Assoluto;