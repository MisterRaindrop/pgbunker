# pgBunker Test Certificates

The certificates in this directory are used for testing purposes only and are not used for actual services. They are used only by the unit and integration tests and there should be no reason to modify them unless new tests are required.

## Generating the Test CA (pgbunker-test-ca.crt/key)

This is a self-signed CA that is used to sign all server certificates. No intermediate CAs will be generated since they are not needed for testing.

```
cd [pgbunker-root]/test/certificate
openssl genrsa -out pgbunker-test-ca.key 4096
openssl req -new -x509 -extensions v3_ca -key pgbunker-test-ca.key -out pgbunker-test-ca.crt -days 99999 \
    -subj "/C=US/ST=All/L=All/O=pgBunker/CN=test.pgbackrest.org"
openssl x509 -in pgbunker-test-ca.crt -text -noout
```

## Generating the Server Test Key (pgbunker-test-server.key)

This key will be used for all server certificates to keep things simple.

```
cd [pgbunker-root]/test/certificate
openssl genrsa -out pgbunker-test-server.key 4096
```

## Generating the Server Test Certificate (pgbunker-test-server.crt/key)

This certificate will be used in unit and integration tests. It is expected to pass verification but won't be subjected to extensive testing.

```
cd [pgbunker-root]/test/certificate
openssl req -new -sha256 -nodes -out pgbunker-test-server.csr -key pgbunker-test-server.key -config pgbunker-test-server.cnf
openssl x509 -req -in pgbunker-test-server.csr -CA pgbunker-test-ca.crt -CAkey pgbunker-test-ca.key -CAcreateserial \
    -out pgbunker-test-server.crt -days 99999 -extensions v3_req -extfile pgbunker-test-server.cnf
openssl x509 -in pgbunker-test-server.crt -text -noout
```

## Generating the Client Test Key (pgbunker-test-client.key)

This key will be used for all client certificates to keep things simple.

```
cd [pgbunker-root]/test/certificate
openssl genrsa -out pgbunker-test-client.key 4096
```

## Generating the Client Test Certificate (pgbunker-test-client.crt/key)

This certificate will be used in unit and integration tests. It is expected to pass verification but won't be subjected to extensive testing.

```
cd [pgbunker-root]/test/certificate
openssl req -new -sha256 -nodes -out pgbunker-test-client.csr -key pgbunker-test-client.key -config pgbunker-test-client.cnf
openssl x509 -req -in pgbunker-test-client.csr -CA pgbunker-test-ca.crt -CAkey pgbunker-test-ca.key -CAcreateserial \
    -out pgbunker-test-client.crt -days 99999 -extensions v3_req -extfile pgbunker-test-client.cnf
openssl x509 -in pgbunker-test-client.crt -text -noout
```
