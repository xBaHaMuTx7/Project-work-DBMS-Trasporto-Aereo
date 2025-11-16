/* --------------------------------------------------------------------------
 * ALFIO CASTIGLIONE - Airline Ticketing System
 * --------------------------------------------------------------------------
 * QUERIES SQL
 * --------------------------------------------------------------------------
 * Ambiente: Oracle Database XE21 (Da eseguire in SQL Developer)
*/ --------------------------------------------------------------------------
 
 
/* --------------------------------------------------------------------------    
     2. Verifica Validità di un Biglietto con Dettagli della Corsa.
        Fornisce anche dettagli sulla corsa
        associata al biglietto
*/ --------------------------------------------------------------------------

    SELECT
        B.IDBiglietto as id_biglietto,
        P.Stato AS Stato_Prenotazione,
        V.DataVolo as Data_volo,
        V.STATO AS Stato_Volo,
        T.CodiceTratta as tratta,
        A_Partenza.Nome AS Aeroporto_di_Partenza,
        A_Arrivo.Nome AS Aeroporto_di_Arrivo 
    FROM BIGLIETTI B
        JOIN PRENOTAZIONI P 
            ON B.IDPrenotazioneFK = P.IDPrenotazione
        JOIN DETTAGLI_BIGLIETTI_VOLI DBV 
            ON B.IDBiglietto = DBV.IDBigliettoFK
        JOIN VOLI V 
             ON DBV.IDVoloFK = V.IDVolo
        JOIN TRATTE T 
            ON V.CodiceTrattaFK = T.CodiceTratta
        JOIN AEROPORTI A_Partenza 
            ON T.OrigineFK = A_Partenza.CodiceAeroporto   
        JOIN AEROPORTI A_Arrivo 
            ON T.DestinazioneFK = A_Arrivo.CodiceAeroporto 
    WHERE B.IDBiglietto = 'TKT-987665'
    ORDER BY V.DataVolo;