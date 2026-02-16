-- =========================================
-- Parking Management DB (PostgreSQL)
-- Academic schema recreated from MS Access model
-- =========================================
-- ---------------------------
-- LOOKUP TABLES
-- ---------------------------

CREATE TABLE riik (
    riik_kood   VARCHAR(2) PRIMARY KEY,
    nimetus     VARCHAR(100) NOT NULL,
    on_aktiivne BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_riik_kood_format CHECK (riik_kood ~ '^[A-Za-z]{2}$')
);

CREATE TABLE isiku_seisundi_liik (
    isiku_seisundi_liik_kood INTEGER PRIMARY KEY,
    nimetus                  VARCHAR(100) NOT NULL,
    on_aktiivne              BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE kliendi_seisundi_liik (
    kliendi_seisundi_liik_kood INTEGER PRIMARY KEY,
    nimetus                    VARCHAR(100) NOT NULL,
    on_aktiivne                BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE tootaja_seisundi_liik (
    tootaja_seisundi_liik_kood INTEGER PRIMARY KEY,
    nimetus                    VARCHAR(100) NOT NULL,
    on_aktiivne                BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE parkimiskoha_suurus (
    suurus_kood INTEGER PRIMARY KEY,
    nimetus     VARCHAR(100) NOT NULL,
    on_aktiivne BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE parkimiskoha_seisundi_liik (
    parkimiskoha_seisundi_liik_kood INTEGER PRIMARY KEY,
    nimetus                          VARCHAR(100) NOT NULL,
    on_aktiivne                      BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE parkimiskoha_aadress (
    aadress_kood INTEGER PRIMARY KEY,
    on_aktiivne  BOOLEAN NOT NULL DEFAULT TRUE,
    postindeks   VARCHAR(20),
    aadress      VARCHAR(255) NOT NULL
);

CREATE TABLE parkimiskoha_kategooria_tyyp (
    parkimiskoha_kategooria_tyyp_kood INTEGER PRIMARY KEY,
    nimetus                            VARCHAR(100) NOT NULL,
    on_aktiivne                        BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE parkimiskoha_kategooria (
    parkimiskoha_kategooria_kood       INTEGER PRIMARY KEY,
    nimetus                            VARCHAR(100) NOT NULL,
    on_aktiivne                        BOOLEAN NOT NULL DEFAULT TRUE,
    parkimiskoha_kategooria_tyyp_kood  INTEGER NOT NULL,
    CONSTRAINT fk_kategooria_tyyp
        FOREIGN KEY (parkimiskoha_kategooria_tyyp_kood)
        REFERENCES parkimiskoha_kategooria_tyyp(parkimiskoha_kategooria_tyyp_kood)
);

CREATE TABLE tootaja_roll (
    tootaja_roll_kood INTEGER PRIMARY KEY,
    nimetus           VARCHAR(100) NOT NULL,
    kirjeldus         TEXT,
    on_aktiivne       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE isik (
    isik_id                 INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    isikukood               VARCHAR(50) NOT NULL,
    riik_kood               VARCHAR(2) NOT NULL,
    e_meil                  VARCHAR(255),
    isiku_seisundi_liik_kood INTEGER NOT NULL,
    synni_kp                DATE,
    reg_aeg                 TIMESTAMP NOT NULL,
    viimase_muutm_aeg       TIMESTAMP,
    eesnimi                 VARCHAR(100),
    perenimi                VARCHAR(100),
    elukoht                 VARCHAR(255),

    CONSTRAINT uq_isik_isikukood UNIQUE (isikukood),

    CONSTRAINT fk_isik_riik
        FOREIGN KEY (riik_kood)
        REFERENCES riik(riik_kood),

    CONSTRAINT fk_isik_seisund
        FOREIGN KEY (isiku_seisundi_liik_kood)
        REFERENCES isiku_seisundi_liik(isiku_seisundi_liik_kood)
);

CREATE TABLE kasutajakonto (
    isik_id     INTEGER PRIMARY KEY,
    parool      VARCHAR(255) NOT NULL,
    on_aktiivne BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_kasutajakonto_isik
        FOREIGN KEY (isik_id)
        REFERENCES isik(isik_id)
        ON DELETE CASCADE
);

CREATE TABLE klient (
    isik_id                 INTEGER PRIMARY KEY,
    kliendi_seisundi_liik_kood INTEGER NOT NULL,
    on_nous_tyltamisega     BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_klient_isik
        FOREIGN KEY (isik_id)
        REFERENCES isik(isik_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_klient_seisund
        FOREIGN KEY (kliendi_seisundi_liik_kood)
        REFERENCES kliendi_seisundi_liik(kliendi_seisundi_liik_kood)
);

CREATE TABLE tootaja (
    isik_id                    INTEGER PRIMARY KEY,
    tootaja_seisundi_liik_kood INTEGER NOT NULL,
    mentor                     BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_tootaja_isik
        FOREIGN KEY (isik_id)
        REFERENCES isik(isik_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_tootaja_seisund
        FOREIGN KEY (tootaja_seisundi_liik_kood)
        REFERENCES tootaja_seisundi_liik(tootaja_seisundi_liik_kood)
);

CREATE TABLE parkimiskoht (
    parkimiskoht_kood               INTEGER PRIMARY KEY,
    registreerija_id                INTEGER NOT NULL,
    viimase_muutja_id               INTEGER NOT NULL,
    suurus_kood                     INTEGER NOT NULL,
    parkimiskoha_seisundi_liik_kood INTEGER NOT NULL,
    aadress_kood                    INTEGER NOT NULL,
    reg_aeg                         TIMESTAMP NOT NULL,
    viimase_muutm_aeg               TIMESTAMP,
    kommentaar                      TEXT,
    number                          VARCHAR(20) NOT NULL,

    CONSTRAINT fk_parkimiskoht_suurus
        FOREIGN KEY (suurus_kood)
        REFERENCES parkimiskoha_suurus(suurus_kood),

    CONSTRAINT fk_parkimiskoht_seisund
        FOREIGN KEY (parkimiskoha_seisundi_liik_kood)
        REFERENCES parkimiskoha_seisundi_liik(parkimiskoha_seisundi_liik_kood),

    CONSTRAINT fk_parkimiskoht_aadress
        FOREIGN KEY (aadress_kood)
        REFERENCES parkimiskoha_aadress(aadress_kood),

    CONSTRAINT fk_parkimiskoht_registreerija
        FOREIGN KEY (registreerija_id)
        REFERENCES tootaja(isik_id),

    CONSTRAINT fk_parkimiskoht_muutja
        FOREIGN KEY (viimase_muutja_id)
        REFERENCES tootaja(isik_id)
);

CREATE TABLE parkimiskoha_kategooria_omamine (
    parkimiskoht_kood            INTEGER NOT NULL,
    parkimiskoha_kategooria_kood INTEGER NOT NULL,

    PRIMARY KEY (parkimiskoht_kood, parkimiskoha_kategooria_kood),

    CONSTRAINT fk_pkko_parkimiskoht
        FOREIGN KEY (parkimiskoht_kood)
        REFERENCES parkimiskoht(parkimiskoht_kood)
        ON DELETE CASCADE,

    CONSTRAINT fk_pkko_kategooria
        FOREIGN KEY (parkimiskoha_kategooria_kood)
        REFERENCES parkimiskoha_kategooria(parkimiskoha_kategooria_kood)
        ON DELETE RESTRICT
);

CREATE TABLE tootaja_rolli_omamine (
    tootaja_rolli_omamine_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    isik_id                  INTEGER NOT NULL,
    tootaja_roll_kood        INTEGER NOT NULL,
    alguse_aeg               TIMESTAMP NOT NULL,
    lopu_aeg                 TIMESTAMP,

    CONSTRAINT fk_tro_tootaja
        FOREIGN KEY (isik_id)
        REFERENCES tootaja(isik_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_tro_roll
        FOREIGN KEY (tootaja_roll_kood)
        REFERENCES tootaja_roll(tootaja_roll_kood),

    CONSTRAINT chk_tro_dates
        CHECK (lopu_aeg IS NULL OR lopu_aeg >= alguse_aeg)
);
