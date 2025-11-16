/* --------------------------------------------------------------------------
 * ALFIO CASTIGLIONE - Airline Ticketing System
 * --------------------------------------------------------------------------
 * QUERIES SQL
 * --------------------------------------------------------------------------
 * Ambiente: Oracle Database XE21 (Da eseguire in SQL Developer)
*/ --------------------------------------------------------------------------
 
/* --------------------------------------------------------------------------    
     5. Verifica tutti i voli con scalo prenotati.
     Restituisce aereoporti di partenza, aereoporto di scalo e di arrivo.
     Include anche gli orari per verificare che ci sia coerenza tra i vari orari
     di partenza e di arrivo.
*/ --------------------------------------------------------------------------
    WITH BigliettiConScalo AS (
        -- 1. Identifica gli ID dei biglietti che hanno più di un segmento di volo.
        SELECT
            IDBigliettoFK
        FROM
            DETTAGLI_BIGLIETTI_VOLI
        GROUP BY
            IDBigliettoFK
        HAVING
            COUNT(IDVoloFK) > 1
    )
    -- 2. Estrai i dettagli dei segmenti di volo che formano uno scalo temporalmente valido.
    SELECT
        B.IDBiglietto AS Biglietto,
        P.Nome || ' ' || P.Cognome AS Passeggero,
        V1.IDVolo AS Volo_Partenza,
        TR_1.OrigineFK AS Origine_Finale,
        V1.OraPartenzaPrevista AS Partenza_Volo_1,
        V1.OraArrivoPrevista AS Arrivo_Volo_1,
        TR_1.DestinazioneFK AS Aeroporto_Scalo,
        V2.OraPartenzaPrevista AS Partenza_Volo_2,
        V2.IDVolo AS Volo_2_Arrivo,
        V2.OraArrivoPrevista AS Arrivo_Finale,
        TR_2.DestinazioneFK AS Destinazione_Finale
    FROM BIGLIETTI B 
        INNER JOIN BigliettiConScalo BCS 
            ON B.IDBiglietto = BCS.IDBigliettoFK
        INNER JOIN PRENOTAZIONI PR 
            ON B.IDPrenotazioneFK = PR.IDPrenotazione
        INNER JOIN PASSEGGERI P 
            ON PR.CodiceFiscalePasseggeroFK = P.CodiceFiscale
        INNER JOIN DETTAGLI_BIGLIETTI_VOLI DBV1 
            ON B.IDBiglietto = DBV1.IDBigliettoFK
        INNER JOIN VOLI V1 
            ON DBV1.IDVoloFK = V1.IDVolo
        INNER JOIN TRATTE TR_1 
            ON V1.CodiceTrattaFK = TR_1.CodiceTratta
        INNER JOIN DETTAGLI_BIGLIETTI_VOLI DBV2 
            ON B.IDBiglietto = DBV2.IDBigliettoFK
        INNER JOIN VOLI V2 
            ON DBV2.IDVoloFK = V2.IDVolo
        INNER JOIN TRATTE TR_2 
            ON V2.CodiceTrattaFK = TR_2.CodiceTratta
    WHERE TR_1.DestinazioneFK = TR_2.OrigineFK
      AND V2.OraPartenzaPrevista > V1.OraArrivoPrevista
      AND V1.IDVolo < V2.IDVolo
    ORDER BY B.IDBiglietto, V1.OraPartenzaPrevista;