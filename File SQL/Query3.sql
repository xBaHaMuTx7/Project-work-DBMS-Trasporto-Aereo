/* --------------------------------------------------------------------------
 * ALFIO CASTIGLIONE - Airline Ticketing System
 * --------------------------------------------------------------------------
 * QUERIES SQL
 * --------------------------------------------------------------------------
 * Ambiente: Oracle Database XE21 (Da eseguire in SQL Developer)
*/ --------------------------------------------------------------------------
 
 
/* --------------------------------------------------------------------------
    3. Ricerca di Biglietti Disponibili per Tratta e Posti Liberi. 
       Simile alla prima query ma con complessitá piú elevata,
       genera piú dettagli e prevede variabili pre dichiarate e assegnate.
       Con variabili di Binding simula l'input di un semplice motore 
       di ricerca web per la prenotazione dei biglietti.
*/ --------------------------------------------------------------------------    
 
// Dichiarazione Variabili
    VARIABLE CODICE_TRATTA_DESIDERATO VARCHAR2(10); 
    VARIABLE DATA_DEL_VOLO VARCHAR2(10); 
    VARIABLE NUMERO_MINIMO_POSTI_LIBERI NUMBER; 
// Assegnazione variabili
    EXEC :CODICE_TRATTA_DESIDERATO := 'RM-LD';
    EXEC :DATA_DEL_VOLO := '2026-03-10';
    EXEC :NUMERO_MINIMO_POSTI_LIBERI := 200;

    SELECT
        V.IDVolo,                                                
        V.DataVolo,
        TO_CHAR(V.OraPartenzaPrevista, 'HH24:MI') AS Ora_Partenza, 
        T.CodiceTratta,
        AP.Nome AS Aeroporto_Origine,                            
        AA.Nome AS Aeroporto_Destinazione,                       
        A.Modello AS Aeromobile_Modello,                         
        A.CapacitaTotale AS Capacita_Massima,
        COUNT(DBV.IDBigliettoFK) AS Posti_Venduti,
        (A.CapacitaTotale - COUNT(DBV.IDBigliettoFK)) AS Posti_Disponibili
    FROM VOLI V
        JOIN TRATTE T 
            ON V.CodiceTrattaFK = T.CodiceTratta
        JOIN AEROPORTI AP 
            ON T.OrigineFK = AP.CodiceAeroporto         
        JOIN AEROPORTI AA 
            ON T.DestinazioneFK = AA.CodiceAeroporto    
        JOIN AEROMOBILI A 
            ON V.MatricolaAeromobileFK = A.Matricola
        LEFT JOIN DETTAGLI_BIGLIETTI_VOLI DBV 
            ON V.IDVolo = DBV.IDVoloFK
    WHERE T.CodiceTratta = :CODICE_TRATTA_DESIDERATO
      AND V.DataVolo = TO_DATE(:DATA_DEL_VOLO, 'YYYY-MM-DD')
      AND V.STATO = 'PROGRAMMATO' 
    GROUP BY V.IDVolo, V.DataVolo, V.OraPartenzaPrevista, T.CodiceTratta,
             A.CapacitaTotale, A.Modello, AP.Nome, AA.Nome 
    HAVING (A.CapacitaTotale - COUNT(DBV.IDBigliettoFK)) >= :NUMERO_MINIMO_POSTI_LIBERI
    ORDER BY Ora_Partenza, Posti_Disponibili DESC;