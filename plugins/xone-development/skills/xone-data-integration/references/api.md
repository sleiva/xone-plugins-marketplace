# XOne Data Integration: API

## SqlManager

`new SqlManager()` -> `openDatabase({databasePath, useExistingConnection})` -> `doRawQuery(sql, ...)`, `insert({tableName, fields})`, `doBatchParseSqls`, `doWalCheckpoint`, `doVacuum` -> `close()`. El cursor expone `getCount`, `moveToFirst`, `getString`, `getInteger` y `close`. `appData.executeSql(sql)` sirve para SQL directo con valores previamente validados.

## HTTP

`$http.get(url, [request], ok, err)`, `post`, `put`, `delete`, `patch` y `download`. El éxito de download recibe la ruta local. El future admite `cancel()`. `request.parameters` admite `connectTimeout`, `readTimeout`, `allowUnsafeCertificates`, `enablePinning`, `allowedRootCas`, `dumpCertificateChainPath` y proxy; `privateKey`/`certificateChain` cubren mTLS. `$http.setMock(url, status, body, headers)` registra mocks en código.

## OAuth2, réplica y crypto

OAuth2: `withOptions` acepta `authority`, `clientID`, `clientSecret`, `scope`, `responseType`, `persistenceKey` y `redirectUri`; luego `authenticate({onSuccess,onError})` o `logout()`.

Réplica: `replica.start()`, `processReplicatorQueue(callback)` y `appData.isReplicating()`.

`appData.encryptString`/`decryptString`; `crypto.sha256`, `generateAesKey`, `encrypt`, `generateKeyPair`, `sign`, `toBase64` y `getChecksum`.
