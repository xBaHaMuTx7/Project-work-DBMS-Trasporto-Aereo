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
    WHERE B.IDBiglietto = 'TKT-987665' -- INPUT ID_BIGLIETTO
    ORDER BY V.DataVolo;

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
        
/* --------------------------------------------------------------------------    
     4. Storico prenotazione biglietti per uno specifico cliente. 
        Aggrega i dati transazionali (BIGLIETTI) in una visione riepilogativa, 
        calcolando il numero totale di biglietti comprati e inserendo dettagli 
        su tariffa, classe di viaggio, prezzo, date.
*/ --------------------------------------------------------------------------  
    
    SELECT
        P.Nome AS Nome_Passeggero,
        P.Cognome AS Cognome_Passeggero,
        PR.IDPrenotazione,
        PR.DataPrenotazione,
        PR.Stato AS Stato_Prenotazione,
        B.IDBiglietto,
        B.DataEmissione,
        B.PrezzoFinale,
        C.Descrizione AS Classe_Viaggio,
        T.NomeTariffa AS Nome_Tariffa
    FROM PASSEGGERI P
        JOIN PRENOTAZIONI PR 
            ON P.CodiceFiscale = PR.CodiceFiscalePasseggeroFK
        JOIN BIGLIETTI B 
            ON PR.IDPrenotazione = B.IDPrenotazioneFK
        JOIN CLASSI_DI_VIAGGIO C 
            ON B.CodiceClasseFK = C.CodiceClasse
        JOIN TARIFFE T 
            ON B.CodiceTariffaFK = T.CodiceTariffa
    WHERE P.CodiceFiscale = 'RSSMRA80A01H501K' -- Dato di input
    ORDER BY B.DataEmissione DESC;
    
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

    
