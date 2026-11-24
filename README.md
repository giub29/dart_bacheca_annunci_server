# Bacheca lavoro — Server Dart

Back-end della bacheca di annunci di lavoro sviluppata per il compito di Enterprise Mobile Application Development.

Il server viene eseguito su un computer locale e gestisce account aziendali, annunci, candidature e curriculum. Espone le API utilizzate dall’[app Flutter](https://github.com/giub29/flutter_bacheca_annunci).

È realizzato in Dart con `shelf` e `shelf_router`. Non utilizza Firebase, Supabase o altri servizi esterni per conservare i dati.

## Avvio

Serve il Dart SDK, disponibile anche con l’installazione di Flutter.

Aprire un terminale nella cartella principale della repository ed eseguire:

```sh
dart pub get
dart run bin/server.dart
```

Il server ascolta sulla porta `8080`. Il terminale deve rimanere aperto durante l’utilizzo dell’app.

Per controllare che sia raggiungibile, aprire sul computer:

```text
http://localhost:8080/api/health
```

La risposta prevista è:

```json
{"status":"ok"}
```

Per arrestare il server premere `Ctrl+C`.

## Salvataggio dei dati

Il server usa file JSON e una cartella per i PDF:

```text
data/
  aziende.json
  annunci.json
  candidature.json
  cv/
```

Gli archivi vengono caricati all’avvio e scritti quando vengono aggiunti nuovi dati. I file necessari vengono creati durante l’utilizzo: una nuova installazione parte senza account o annunci predefiniti.

La cartella `data` è esclusa da Git. Per conservare i dati tra un avvio e l’altro non bisogna cancellarla. Il server va avviato dalla cartella principale del progetto, perché i percorsi sono relativi a quella posizione.

I PDF vengono salvati con nomi generati dal server. Il nome originale è conservato nei dati della candidatura per essere mostrato nell’app.

## Autenticazione e accesso ai dati

La registrazione crea l’account aziendale; il login restituisce un token che il client invia nelle richieste riservate:

```text
Authorization: Bearer TOKEN
```

Le password vengono conservate come hash con salt. La gestione segue l’impostazione didattica del progetto.

Le sessioni sono mantenute in memoria. Il logout invalida il token e il riavvio del server richiede un nuovo login, senza eliminare account, annunci o candidature.

Il candidato non deve autenticarsi. L’accesso alle candidature e ai curriculum è invece consentito soltanto all’azienda proprietaria dell’annuncio.

## API

| Metodo | Percorso | Operazione |
|---|---|---|
| GET | `/api/health` | Verifica del server |
| POST | `/api/auth/register` | Registrazione aziendale |
| POST | `/api/auth/login` | Login |
| GET | `/api/auth/me` | Dati dell’azienda autenticata |
| POST | `/api/auth/logout` | Logout |
| GET | `/api/annunci` | Bacheca pubblica |
| GET | `/api/annunci/<id>` | Dettaglio annuncio |
| POST | `/api/annunci` | Pubblicazione, con autenticazione |
| GET | `/api/azienda/annunci` | Annunci dell’azienda autenticata |
| POST | `/api/annunci/<id>/candidature` | Invio di una candidatura anonima |
| GET | `/api/annunci/<id>/candidature` | Candidature, riservate all’azienda proprietaria |
| GET | `/api/candidature/<id>/cv` | Download del PDF, riservato all’azienda proprietaria |

Le richieste e le risposte utilizzano JSON, tranne il download del curriculum, che restituisce direttamente un PDF.

Per inviare una candidatura il client trasmette `nome`, `cognome`, `email`, `cvNomeOriginale` e `cvBase64`. Il curriculum è codificato in Base64 per inserirlo nel JSON; il server lo decodifica e salva i byte su disco.

Sono accettati PDF fino a 5 MiB. Il server controlla anche i campi obbligatori, il formato dell’email e l’intestazione del file.

## Organizzazione del progetto

- `bin/server.dart`: avvio, caricamento degli archivi e collegamento delle API;
- `lib/controllers`: gestione delle richieste;
- `lib/dao`: accesso agli archivi JSON;
- `lib/models`: modelli dei dati;
- `lib/middleware`: autenticazione e gestione degli errori;
- `lib/services`: password, token e file CV;
- `lib/utils`: lettura e validazione dei dati;
- `lib/errors`: eccezioni dell’API.

## Collegamento con il telefono

Il server deve restare raggiungibile durante l’utilizzo e la registrazione dei video. Per le prove su Android è stato utilizzato il collegamento USB con `adb reverse`; i comandi sono riportati nel README del front-end.

Per controllare il codice:

```sh
dart analyze
```
