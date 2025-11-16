/* --------------------------------------------------------------------------
 * ALFIO CASTIGLIONE - Airline Ticketing System
 * --------------------------------------------------------------------------
 * QUERIES SQL
 * --------------------------------------------------------------------------
 * Ambiente: Oracle Database XE21 (Da eseguire in SQL Developer)
*/ --------------------------------------------------------------------------
 
 
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
    WHERE P.CodiceFiscale = 'RSSMRA80A01H501K'
    ORDER BY B.DataEmissione DESC;