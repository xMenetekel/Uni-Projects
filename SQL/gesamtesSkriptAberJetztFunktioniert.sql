drop table a_bewohner cascade constraints;
drop table a_braucht cascade constraints;
drop table a_buffs cascade constraints;
drop table a_feldfrucht cascade constraints;
drop table a_kategorie cascade constraints;
drop table a_liebt cascade constraints;
drop table a_loesen_aus cascade constraints;
drop table a_rezepte cascade constraints;
commit;


create Table A_Buffs (
    BuffID INTEGER PRIMARY KEY,
    BuffName VARCHAR2(200),
    Effekt VARCHAR2(200) NOT NULL
);

create Table A_Bewohner (
    BewohnerID INTEGER PRIMARY KEY,
    BewohnerName VARCHAR2(200),
    Wohnort VARCHAR2(200) NOT NULL,
    Adresse VARCHAR2(200) NOT NULL,
    Geburtstag DATE NOT NULL,
    Heiratbar NUMBER(1) NOT NULL
);

create Table A_Rezepte (
    RezeptID INTEGER PRIMARY KEY,
    RezeptName VARCHAR2(200),
    Energie INTEGER,
    Verkaufspreis INTEGER NOT NULL,
    Beschreibung VARCHAR2(200),
    Buffdauer INTEGER,
    Gesundheit INTEGER
);

create Table A_Kategorie (
    KategorieID INTEGER PRIMARY KEY,
    KategorieName VARCHAR2(200) NOT NULL
);

Create Table A_Feldfrucht (
    FruchtID INTEGER PRIMARY KEY,
    FruchtName VARCHAR2(200) NOT NULL,
    Einkaufspreis INTEGER,
    Ernteanzahl INTEGER NOT NULL,
    Aussaehungsjahreszeit VARCHAR2(200) NOT NULL,   
    VerkaufspreisNormal INTEGER NOT NULL,
    VerkaufspreisSilber INTEGER NOT NULL,
    VerkaufspreisGold INTEGER NOT NULL,
    VerkaufspreisIridium INTEGER NOT NULL,
    KategorieID INTEGER NOT NULL,
    FOREIGN KEY (KategorieID) REFERENCES A_Kategorie(KategorieID)
);

create Table A_loesen_aus (
    BuffID INTEGER,
    RezeptID INTEGER,
    PRIMARY KEY (BuffID, RezeptID),
    FOREIGN KEY (BuffID) REFERENCES A_Buffs(BuffID),
    FOREIGN KEY (RezeptID) REFERENCES A_Rezepte(RezeptID)
);

create Table A_liebt (
    RezeptID INTEGER,
    BewohnerID INTEGER,
    PRIMARY KEY (RezeptID, BewohnerID),
    FOREIGN KEY (RezeptID) REFERENCES A_Rezepte(RezeptID),
    FOREIGN KEY (BewohnerID) REFERENCES A_Bewohner(BewohnerID)
);

create Table A_braucht (
    RezeptID INTEGER,
    FruchtID INTEGER,
    PRIMARY KEY (RezeptID, FruchtID),
    FOREIGN KEY (RezeptID) REFERENCES A_Rezepte(RezeptID),
    FOREIGN KEY (FruchtID) REFERENCES A_Feldfrucht(FruchtID)
);


-- Trigger für gültige Werte bei A_Bewohner.Heiratbar
/
CREATE OR REPLACE TRIGGER trg_check_heiratbar
BEFORE INSERT OR UPDATE ON A_Bewohner
FOR EACH ROW
BEGIN
    IF :NEW.Heiratbar NOT IN (0, 1) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Heiratbar muss 0 oder 1 sein');
    END IF;
END;
/

-- Prüft, ob Verkaufspreise in aufsteigender Reihenfolge sind
/
CREATE OR REPLACE TRIGGER trg_check_preise
BEFORE INSERT OR UPDATE ON A_Feldfrucht
FOR EACH ROW
BEGIN
    IF :NEW.VerkaufspreisNormal > :NEW.VerkaufspreisSilber OR
       :NEW.VerkaufspreisSilber > :NEW.VerkaufspreisGold OR
       :NEW.VerkaufspreisGold > :NEW.VerkaufspreisIridium THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'Verkaufspreise müssen in aufsteigender Reihenfolge sein: Normal < Silber < Gold < Iridium');
    END IF;
END;
/



-- HEIRATSBARE BEWOHNER (12 Charaktere)
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (1, 'Abigail', 'Sterntautal', 'Warenhaus', DATE '1997-02-13', 1);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (2, 'Alex', 'Sterntautal', 'Saloon-Straße 1', DATE '1996-07-13', 1);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (3, 'Elliott', 'Sterntautal', 'Strandhütte', DATE '1988-10-05', 1);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (4, 'Emily', 'Sterntautal', 'Saloon-Straße 2', DATE '1995-03-27', 1);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (5, 'Haley', 'Sterntautal', 'Saloon-Straße 2', DATE '1996-04-14', 1);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (6, 'Harvey', 'Sterntautal', 'Krankenhaus', DATE '1980-06-14', 1);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (7, 'Leah', 'Sterntautal', 'Waldhütte', DATE '1991-12-23', 1);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (8, 'Maru', 'Sterntautal', 'Bergstraße 7', DATE '1994-08-10', 1);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (9, 'Penny', 'Sterntautal', 'Anhänger 6', DATE '1996-09-02', 1);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (10, 'Sam', 'Sterntautal', 'Saloon-Straße 1', DATE '1995-08-17', 1);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (11, 'Sebastian', 'Sterntautal', 'Bergstraße 7', DATE '1993-10-12', 1);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (12, 'Shane', 'Sterntautal', 'Marnies Ranch', DATE '1989-04-20', 1);

-- NICHT-HEIRATSBARE BEWOHNER (Erwachsene)
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (13, 'Caroline', 'Sterntautal', 'Warenhaus', DATE '1970-01-07', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (14, 'Clint', 'Sterntautal', 'Schmiede', DATE '1972-11-15', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (15, 'Demetrius', 'Sterntautal', 'Bergstraße 7', DATE '1968-03-19', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (16, 'Evelyn', 'Sterntautal', 'Saloon-Straße 1', DATE '1942-07-20', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (17, 'George', 'Sterntautal', 'Saloon-Straße 1', DATE '1938-10-24', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (18, 'Gus', 'Sterntautal', 'Saloon', DATE '1965-08-08', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (19, 'Jas', 'Sterntautal', 'Marnies Ranch', DATE '2012-08-04', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (20, 'Jodi', 'Sterntautal', 'Saloon-Straße 1', DATE '1975-05-11', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (21, 'Kent', 'Sterntautal', 'Saloon-Straße 1', DATE '1973-03-04', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (22, 'Lewis', 'Sterntautal', 'Bürgermeisterhaus', DATE '1950-04-30', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (23, 'Linus', 'Sterntautal', 'Zelt am Berg', DATE '1955-12-03', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (24, 'Marnie', 'Sterntautal', 'Marnies Ranch', DATE '1962-09-18', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (25, 'Pam', 'Sterntautal', 'Anhänger 6', DATE '1960-11-18', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (26, 'Pierre', 'Sterntautal', 'Warenhaus', DATE '1968-03-26', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (27, 'Robin', 'Sterntautal', 'Bergstraße 7', DATE '1971-09-21', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (28, 'Sandy', 'Calico Wüste', 'Oasis', DATE '1982-10-15', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (29, 'Vincent', 'Sterntautal', 'Saloon-Straße 1', DATE '2010-03-10', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (30, 'Willy', 'Sterntautal', 'Fischgeschäft', DATE '1958-06-24', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (31, 'Wizard', 'Sterntautal', 'Turm', DATE '1950-01-01', 0);


-- DORFBEWOHNER VON GINGER ISLAND 
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (32, 'Leo', 'Ginger Island', 'Dschungel', DATE '2014-07-26', 0);
INSERT INTO A_BEWOHNER (BewohnerID, BewohnerName, Wohnort, Adresse, Geburtstag, Heiratbar) VALUES (33, 'Birdie', 'Ginger Island', 'Inselhütte', DATE '1940-05-05', 0);

-- FRÜHJAHRS REZEPTE (ab TV Level 1)
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (1, 'Gebratene Pilze', 65, 200, 'Saftige gebratene Pilze', 0, 29);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (2, 'Gemüseeintopf', 100, 120, 'Warmer herzhafter Eintopf', 0, 45);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (3, 'Omelett', 100, 125, 'Fluffiges Ei-Omelett', 0, 45);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (4, 'Sashimi', 75, 75, 'Roher frischer Fisch', 0, 33);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (5, 'Frühlingsrolle', 90, 120, 'Gefüllte Frühlingsrolle', 0, 40);

-- SOMMER REZEPTE (ab TV Level 2)
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (6, 'Tortilla', 50, 50, 'Einfache Maistortilla', 0, 22);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (7, 'Karpfensushi', 100, 150, 'Sushi mit Karpfen', 0, 45);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (8, 'Wurzelgemüseteller', 125, 250, 'Geröstetes Wurzelgemüse', 0, 56);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (9, 'Tom Kha Suppe', 175, 250, 'Thailändische Kokossuppe', 0, 78);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (10, 'Pfannkuchen', 90, 100, 'Fluffige Pfannkuchen', 0, 40);

-- HERBST REZEPTE (ab TV Level 3)
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (11, 'Kürbissuppe', 200, 300, 'Cremige Kürbissuppe', 0, 90);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (12, 'Fischcurry', 175, 300, 'Würziges Fischcurry', 0, 78);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (13, 'Kürbiskuchen', 175, 375, 'Saisonale Kürbistorte', 0, 78);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (14, 'Rübeneintopf', 225, 300, 'Herzhafter Rübeneintopf', 0, 101);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (15, 'Super-Mahlzeit', 200, 350, 'Energiereiche Mahlzeit', 0, 90);

-- WINTER REZEPTE (ab TV Level 4)
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (16, 'Glücks-Mittagessen', 100, 250, 'Besonderes Mittagessen', 0, 45);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (17, 'Käsefondue', 200, 300, 'Schmelzender Käse', 0, 90);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (18, 'Forelle am Wein', 175, 250, 'Forelle in Wein gegart', 0, 78);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (19, 'Plumpudding', 150, 280, 'Traditionelles Pudding', 0, 67);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (20, 'Rosmarinkartoffeln', 125, 200, 'Knusprige Rosmarinkartoffeln', 0, 56);

-- SPEZIALREZEPTE (von NPCs geschenkt)
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (21, 'Käsekuchen', 150, 200, 'Cremiger Käsekuchen', 0, 67);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (22, 'Schokoladenkuchen', 150, 200, 'Schokoladiger Kuchen', 0, 67);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (23, 'Rhabarberkuchen', 150, 200, 'Saurer Rhabarberkuchen', 0, 67);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (24, 'Blaubeertorte', 175, 250, 'Fruchtige Blaubeertorte', 0, 78);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (25, 'Kokoskuchen', 175, 250, 'Tropischer Kokoskuchen', 0, 78);

-- GETRÄNKE & SPEZIALITÄTEN
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (26, 'Kaffee', 0, 150, 'Belebender Kaffee', 120, 0);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (27, 'Tee', 0, 100, 'Beruhigender Tee', 0, 0);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (28, 'Bier', 0, 200, 'Herbes Bier', 0, 0);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (29, 'Mead', 0, 200, 'Honigwein', 0, 0);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (30, 'Saft', 0, 150, 'Frisch gepresster Saft', 0, 0);

-- BUFF-REZEPTE (mit Buffdauer > 0)
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (31, 'Kürbis-Suppe', 200, 300, 'Cremige Kürbissuppe (+2 Verteidigung)', 240, 90);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (32, 'Lobster Bisque', 225, 205, 'Luxuriöse Hummersuppe (+3 Fischen)', 240, 101);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (33, 'Maple Bar', 225, 300, 'Süßer Ahornsirup-Riegel (+1 Landwirtschaft)', 240, 101);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (34, 'Miners Treat', 125, 200, 'Bergmanns-Snack (+3 Bergbau)', 300, 56);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (35, 'Dish O The Sea', 125, 220, 'Fischgericht (+3 Fischen)', 300, 56);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (36, 'Fried Eel', 75, 120, 'Gebratener Aal (+1 Glück)', 240, 33);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (37, 'Spicy Eel', 115, 175, 'Würziger Aal (+1 Glück, +1 Geschwindigkeit)', 420, 51);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (38, 'Eggplant Parm', 175, 200, 'Auberginen-Parmesan (+1 Bergbau, +1 Verteidigung)', 240, 78);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (39, 'Survival Burger', 125, 180, 'Überlebens-Burger (+3 Bergbau)', 300, 56);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (40, 'Farmer''s Lunch', 200, 150, 'Bauern-Mittagessen (+3 Landwirtschaft)', 300, 90);

-- HÖHERWERTIGE REZEPTE
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (41, 'Cranberry Candy', 125, 175, 'Süße Cranberry-Bonbons', 0, 56);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (42, 'Crispy Bass', 90, 150, 'Knuspriger Barsch', 0, 40);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (43, 'Escargot', 125, 125, 'Französische Schnecken', 0, 56);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (44, 'Fish Taco', 150, 500, 'Mexikanischer Fischtaco', 0, 67);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (45, 'Hashbrowns', 90, 120, 'Kartoffelpuffer', 0, 40);

-- MEHR REZEPTE
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (46, 'Ice Cream', 100, 120, 'Cremiges Eis', 0, 45);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (47, 'Maki Roll', 100, 220, 'Japanische Maki-Rollen', 0, 45);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (48, 'Pale Broth', 125, 150, 'Alte Brühe', 0, 56);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (49, 'Parsnip Soup', 135, 120, 'Pastinakensuppe', 0, 60);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (50, 'Pizza', 150, 300, 'Italienische Pizza', 0, 67);

-- LETZTE REZEPTE
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (51, 'Red Plate', 240, 400, 'Roter Teller (+50 Gesundheit)', 240, 50);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (52, 'Rhubarb Pie', 215, 400, 'Rhabarbertorte', 0, 96);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (53, 'Salmon Dinner', 125, 300, 'Lachs-Abendessen', 0, 56);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (54, 'Spaghetti', 120, 120, 'Italienische Spaghetti', 0, 54);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (55, 'Stir Fry', 135, 350, 'Asiatisches Pfannengericht', 0, 60);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (56, 'Stuffing', 165, 165, 'Traditionelle Füllung', 0, 74);
INSERT INTO A_Rezepte (RezeptID, RezeptName, Energie, Verkaufspreis, Beschreibung, Buffdauer, Gesundheit) VALUES (57, 'Triple Shot Espresso', 0, 450, 'Starker Espresso (+1 Geschwindigkeit)', 420, 0);






-- ENERGY & HEALTH BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (1, 'Energie-Buff', '+50 Energie');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (2, 'Gesundheits-Buff', '+50 Gesundheit');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (3, 'Energie und Gesundheit', '+25 Energie, +25 Gesundheit');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (4, 'Maximal-Energie', '+100 Energie');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (5, 'Maximal-Gesundheit', '+100 Gesundheit');

-- SKILL BUFFS (+1 Level)
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (6, 'Bergbau-Buff', '+1 Bergbau');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (7, 'Angeln-Buff', '+1 Angeln');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (8, 'Landwirtschaft-Buff', '+1 Landwirtschaft');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (9, 'Kampf-Buff', '+1 Kampf');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (10, 'Sammeln-Buff', '+1 Sammeln');

-- SKILL BUFFS (+2 Level)
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (11, 'Bergbau-Buff II', '+2 Bergbau');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (12, 'Angeln-Buff II', '+2 Angeln');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (13, 'Landwirtschaft-Buff II', '+2 Landwirtschaft');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (14, 'Kampf-Buff II', '+2 Kampf');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (15, 'Sammeln-Buff II', '+2 Sammeln');

-- SKILL BUFFS (+3 Level)
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (16, 'Bergbau-Buff III', '+3 Bergbau');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (17, 'Angeln-Buff III', '+3 Angeln');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (18, 'Landwirtschaft-Buff III', '+3 Landwirtschaft');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (19, 'Kampf-Buff III', '+3 Kampf');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (20, 'Sammeln-Buff III', '+3 Sammeln');

-- STAT BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (21, 'Angriff-Buff', '+1 Angriff');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (22, 'Angriff-Buff II', '+2 Angriff');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (23, 'Angriff-Buff III', '+3 Angriff');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (24, 'Verteidigung-Buff', '+1 Verteidigung');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (25, 'Verteidigung-Buff II', '+2 Verteidigung');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (26, 'Verteidigung-Buff III', '+3 Verteidigung');

-- SPEZIAL BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (27, 'Glücks-Buff', '+1 Glück');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (28, 'Glücks-Buff II', '+2 Glück');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (29, 'Glücks-Buff III', '+3 Glück');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (30, 'Geschwindigkeit-Buff', '+1 Geschwindigkeit');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (31, 'Geschwindigkeit-Buff II', '+2 Geschwindigkeit');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (32, 'Geschwindigkeit-Buff III', '+3 Geschwindigkeit');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (33, 'Magnetismus-Buff', 'Magnetismus (Anziehung)');

-- KOMBINATIONS-BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (34, 'Glück und Geschwindigkeit', '+1 Glück, +1 Geschwindigkeit');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (35, 'Glück und Angriff', '+1 Glück, +1 Angriff');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (36, 'Geschwindigkeit und Bergbau', '+1 Geschwindigkeit, +1 Bergbau');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (37, 'Bergbau und Verteidigung', '+1 Bergbau, +1 Verteidigung');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (38, 'Angeln und Glück', '+1 Angeln, +1 Glück');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (39, 'Landwirtschaft und Energie', '+1 Landwirtschaft, +25 Energie');

-- NEGATIVE BUFFS (Debuffs)
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (40, 'Schwäche', '-1 Angriff');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (41, 'Verlangsamung', '-1 Geschwindigkeit');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (42, 'Pech', '-1 Glück');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (43, 'Vergiftung', 'Laufender Schaden');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (44, 'Verwirrung', 'Bewegung umgekehrt');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (45, 'Durst', '-25 Energie');


-- SPEZIALEFFEKTE
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (46, 'Nachtsicht', 'Bessere Sicht in der Nacht');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (47, 'Wasserschutz', 'Kein Energieverlust im Wasser');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (48, 'Feuerschutz', 'Reduzierter Feuerschaden');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (49, 'Giftresistenz', 'Immun gegen Gift');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (50, 'Kälteresistenz', 'Immun gegen Erfrieren');

-- ESSENS-SPEZIFISCHE BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (51, 'Kürbis-Suppe Buff', '+2 Verteidigung');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (52, 'Lobster Bisque Buff', '+3 Angeln');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (53, 'Maple Bar Buff', '+1 Landwirtschaft, +1 Bergbau, +1 Angeln');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (54, 'Miners Treat Buff', '+3 Bergbau');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (55, 'Dish O The Sea Buff', '+3 Angeln');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (56, 'Fried Eel Buff', '+1 Glück');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (57, 'Spicy Eel Buff', '+1 Glück, +1 Geschwindigkeit');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (58, 'Eggplant Parm Buff', '+1 Bergbau, +1 Verteidigung');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (59, 'Survival Burger Buff', '+3 Bergbau');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (60, 'Farmers Lunch Buff', '+3 Landwirtschaft');

-- GETRÄNKE-BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (61, 'Kaffee-Buff', '+1 Geschwindigkeit');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (62, 'Triple Shot Espresso Buff', '+1 Geschwindigkeit (länger)');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (63, 'Grüner Tee Buff', '+1 Verteidigung, +1 Energie');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (64, 'Ginger Ale Buff', '+1 Glück');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (65, 'Roots Platter Buff', '+2 Angriff');

-- BESONDERE ITEM-BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (66, 'Stardrop-Effekt', 'Maximale Energie erhöht');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (67, 'Life Elixir', 'Volle Gesundheit');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (68, 'Oil of Garlic', 'Weniger Monster-Anziehung');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (69, 'Crab Pot Buff', 'Bessere Krabbenfalle-Qualität');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (70, 'Burglar''s Ring Buff', 'Mehr Beute von Monstern');

-- JAHRESZEITEN-BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (71, 'Frühlings-Wachstum', 'Schnelleres Pflanzenwachstum im Frühling');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (72, 'Sommer-Hitze', 'Reduzierter Wasserverbrauch im Sommer');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (73, 'Herbst-Ernte', '+10% Ernteertrag im Herbst');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (74, 'Winter-Fische', 'Bessere Fischqualität im Winter');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (75, 'Regen-Tag', '+2 Angeln an Regentagen');

-- FISCHEREI-SPEZIFISCHE BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (76, 'Angler-Bait Buff', 'Schnelleres Beißen');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (77, 'Tackle Buff', 'Bessere Fischkontrolle');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (78, 'Fisch-Typ Spezial', '+50% Wert für bestimmte Fischarten');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (79, 'Legendärer Fisch Buff', 'Erhöhte Chance auf legendäre Fische');

-- KAMPF-SPEZIFISCHE BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (80, 'Kritischer Treffer', '+5% Kritische Trefferchance');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (81, 'Waffen-Geschwindigkeit', '+10% Angriffsgeschwindigkeit');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (82, 'Rüstungs-Verstärkung', '+10% Rüstungswert');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (83, 'Monster-Loot Buff', '+15% mehr Beute von Monstern');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (84, 'Minen-Tiefen-Buff', 'Weniger Monster in tiefen Minen');

-- SPEZIALE EVENT-BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (85, 'Festtags-Freude', '+3 Glück an Festtagen');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (86, 'Geburtstags-Buff', 'Bessere Geschenke an Geburtstagen');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (87, 'Heirats-Buff', '+2 zu allen Fähigkeiten für 1 Woche');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (88, 'Community Center Buff', '+1 zu allen Fähigkeiten nach Fertigstellung');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (89, 'Museum-Vollständigkeit', '+1 Glück bei vollständigem Museum');

-- TIER-BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (90, 'Glückliche Tiere', 'Bessere Produktqualität von Tieren');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (91, 'Schnelles Wachstum', 'Tiere wachsen schneller');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (92, 'Mehr Wolle', '+20% mehr Wolle von Schafen');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (93, 'Extra Eier', '+10% Chance auf extra Eier');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (94, 'Bessere Milch', '+1 Qualitätsstufe für Milch');

-- PFLANZEN-BUFFS
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (95, 'Schnelles Wachstum', 'Pflanzen wachsen 10% schneller');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (96, 'Wassersparen', '-25% Wasserbedarf');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (97, 'Bessere Qualität', '+10% Chance auf höhere Qualität');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (98, 'Doppelte Ernte', '+5% Chance auf doppelte Ernte');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (99, 'Resistenz', 'Immun gegen Unwetterschäden');
INSERT INTO A_Buffs (BuffID, BuffName, Effekt) VALUES (100, 'Ultimativer Buff', '+2 zu allen Fähigkeiten, +50 Energie, +50 Gesundheit');





-- Zuerst Kategorien einfügen (falls nicht vorhanden)
INSERT INTO A_KATEGORIE (KATEGORIEID, KATEGORIENAME) VALUES (1, 'Gemüse');
INSERT INTO A_KATEGORIE (KATEGORIEID, KATEGORIENAME) VALUES (2, 'Obst');
INSERT INTO A_KATEGORIE (KATEGORIEID, KATEGORIENAME) VALUES (3, 'Blume');
INSERT INTO A_KATEGORIE (KATEGORIEID, KATEGORIENAME) VALUES (4, 'Spezial');

-- FRÜHJAHRS CROPS
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (1, 'Blumenkohl', 80, 1, 'Frühling', 175, 218, 262, 350, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (2, 'Grünkohl', 70, 1, 'Frühling', 110, 137, 165, 220, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (3, 'Kartoffel', 50, 1, 'Frühling', 80, 100, 120, 160, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (4, 'Rettich', 40, 1, 'Frühling', 90, 112, 135, 180, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (5, 'Rhabarber', 100, 1, 'Frühling', 220, 275, 330, 440, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (6, 'Rübe', 20, 1, 'Frühling', 35, 43, 52, 70, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (7, 'Stangensellerie', 150, 1, 'Frühling', 175, 218, 262, 350, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (8, 'Erdbeere', 100, 4, 'Frühling', 120, 150, 180, 240, 2);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (9, 'Tulpe', 20, 1, 'Frühling', 30, 37, 45, 60, 3);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (10, 'Jazzmin', 30, 1, 'Frühling', 50, 62, 75, 100, 3);

-- SOMMER CROPS
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (11, 'Blaubeere', 80, 3, 'Sommer', 50, 62, 75, 100, 2);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (12, 'Mais', 150, 1, 'Sommer,Herbst', 50, 62, 75, 100, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (13, 'Heidelbeere', 40, 1, 'Sommer', 90, 112, 135, 180, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (14, 'Melone', 80, 1, 'Sommer', 250, 312, 375, 500, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (15, 'Pfeffer', 40, 1, 'Sommer', 40, 50, 60, 80, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (16, 'Mohn', 100, 1, 'Sommer', 140, 175, 210, 280, 3);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (17, 'Rote Beete', 20, 1, 'Sommer', 100, 125, 150, 200, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (18, 'Sommer-Spargel', 75, 1, 'Sommer', 125, 156, 187, 250, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (19, 'Tomate', 50, 4, 'Sommer', 60, 75, 90, 120, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (20, 'Sonnenblume', 200, 1, 'Sommer,Herbst', 80, 100, 120, 160, 3);

-- HERBST CROPS
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (21, 'Amaranth', 70, 1, 'Herbst', 150, 187, 225, 300, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (22, 'Artischocke', 30, 1, 'Herbst', 160, 200, 240, 320, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (23, 'Kürbis', 100, 1, 'Herbst', 320, 400, 480, 640, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (24, 'Cranberry', 240, 2, 'Herbst', 75, 93, 112, 150, 2);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (25, 'Aubergine', 20, 5, 'Herbst', 60, 75, 90, 120, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (26, 'Weintraube', 60, 1, 'Herbst', 80, 100, 120, 160, 2);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (27, 'Pilz', 100, 1, 'Herbst', 160, 200, 240, 320, 4);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (28, 'Rübe', 10, 1, 'Herbst', 290, 362, 435, 580, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (29, 'Süßkartoffel', 50, 1, 'Herbst', 120, 150, 180, 240, 1);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (30, 'Schwarzwurzel', 25, 1, 'Winter', 75, 93, 112, 150, 1);

-- SPEZIAL & MEHRJÄHRIGE CROPS
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (31, 'Alte Frucht', 0, 1, 'Jahreszeitenübergreifend', 550, 687, 825, 1100, 4);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (32, 'Kaffee', 2500, 4, 'Frühling,Sommer', 15, 18, 22, 30, 4);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (33, 'Federwurz', 200, 1, 'Jahreszeitenübergreifend', 350, 437, 525, 700, 4);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (34, 'Hopfen', 60, 1, 'Sommer', 25, 31, 37, 50, 4);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (35, 'Reis', 40, 1, 'Frühling', 30, 37, 45, 60, 1);

-- GINGER ISLAND CROPS
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (36, 'Ananas', 100, 1, 'Jahreszeitenübergreifend', 300, 375, 450, 600, 2);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (37, 'Mango', 0, 1, 'Jahreszeitenübergreifend', 200, 250, 300, 400, 2);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (38, 'Banane', 0, 1, 'Jahreszeitenübergreifend', 150, 187, 225, 300, 2);

-- GEWÄCHSHAUS & WINTER (keine normalen Crops, aber z.B. via Gartenbeet)
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (39, 'Kristallfrucht', 0, 1, 'Winter', 150, 187, 225, 300, 4);
INSERT INTO A_Feldfrucht (FRUCHTID, FRUCHTNAME, EINKAUFSPREIS, ERNTEANZAHL, AUSSAEHUNGSJAHRESZEIT, VERKAUFSPREISNORMAL, VERKAUFSPREISSILBER, VERKAUFSPREISGOLD, VERKAUFSPREISIRIDIUM, KATEGORIEID) VALUES (40, 'Winterwurzel', 20, 1, 'Winter', 70, 87, 105, 140, 1);






-- BUFF-REZEPT-ZUORDNUNGEN (welches Rezept welchen Buff auslöst)

-- ENERGIE & GESUNDHEIT BUFFS
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (1, 51);   -- Red Plate (+50 Gesundheit)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (2, 15);   -- Super-Mahlzeit (Energie)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (3, 40);   -- Farmer's Lunch (+Energie & Gesundheit)

-- SKILL BUFFS (+1 Level)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (6, 34);   -- Miners Treat (+1 Bergbau)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (7, 35);   -- Dish O The Sea (+1 Angeln)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (8, 33);   -- Maple Bar (+1 Landwirtschaft)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (9, 50);   -- Roots Platter (+1 Kampf)

-- SKILL BUFFS (+2 Level)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (11, 38);  -- Eggplant Parm (+2 Bergbau/Verteidigung)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (13, 40);  -- Farmer's Lunch (+2 Landwirtschaft)

-- SKILL BUFFS (+3 Level)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (16, 39);  -- Survival Burger (+3 Bergbau)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (17, 32);  -- Lobster Bisque (+3 Angeln)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (18, 40);  -- Farmer's Lunch (+3 Landwirtschaft)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (19, 50);  -- Roots Platter (+3 Kampf)

-- ANGRIFF & VERTEIDIGUNG BUFFS
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (21, 38);  -- Eggplant Parm (+1 Angriff)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (24, 31);  -- Kürbissuppe (+1 Verteidigung)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (25, 31);  -- Kürbissuppe (+2 Verteidigung)

-- GLÜCKS BUFFS
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (27, 36);  -- Fried Eel (+1 Glück)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (28, 16);  -- Glücks-Mittagessen (+2 Glück)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (29, 16);  -- Glücks-Mittagessen (+3 Glück)

-- GESCHWINDIGKEITS BUFFS
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (30, 26);  -- Kaffee (+1 Geschwindigkeit)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (31, 57);  -- Triple Shot Espresso (+2 Geschwindigkeit)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (32, 57);  -- Triple Shot Espresso (+3 Geschwindigkeit)

-- KOMBINATIONS-BUFFS
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (34, 37);  -- Spicy Eel (+1 Glück, +1 Geschwindigkeit)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (35, 38);  -- Eggplant Parm (+1 Glück, +1 Angriff)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (36, 34);  -- Miners Treat (+1 Geschwindigkeit, +1 Bergbau)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (37, 38);  -- Eggplant Parm (+1 Bergbau, +1 Verteidigung)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (38, 35);  -- Dish O The Sea (+1 Angeln, +1 Glück)

-- SPEZIELLE ESSENS-BUFFS
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (51, 31);  -- Kürbis-Suppe Buff
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (52, 32);  -- Lobster Bisque Buff
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (53, 33);  -- Maple Bar Buff
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (54, 34);  -- Miners Treat Buff
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (55, 35);  -- Dish O The Sea Buff
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (56, 36);  -- Fried Eel Buff
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (57, 37);  -- Spicy Eel Buff
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (58, 38);  -- Eggplant Parm Buff
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (59, 39);  -- Survival Burger Buff
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (60, 40);  -- Farmers Lunch Buff

-- GETRÄNKE-BUFFS
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (61, 26);  -- Kaffee-Buff
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (62, 57);  -- Triple Shot Espresso Buff
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (63, 27);  -- Grüner Tee Buff
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (64, 30);  -- Ginger Ale Buff (vereinfacht für Saft)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (65, 40);  -- Roots Platter Buff

-- WEITERE WICHTIGE ZUORDNUNGEN
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (80, 44);  -- Fish Taco (+Kritische Treffer)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (81, 48);  -- Pale Broth (+Angriffsgeschwindigkeit)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (82, 49);  -- Parsnip Soup (+Rüstung)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (83, 53);  -- Salmon Dinner (+Monster-Beute)

-- SPEZIELLE REZEPTE
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (85, 19);  -- Plumpudding (Festtags-Freude)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (86, 21);  -- Käsekuchen (Geburtstags-Buff)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (87, 22);  -- Schokoladenkuchen (Heirats-Buff)

-- MEHRFACH-ZUORDNUNGEN (ein Rezept kann mehrere Buffs haben)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (1, 40);   -- Farmer's Lunch (+Energie)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (18, 41);  -- Farmer's Lunch (+Landwirtschaft)

-- FISCHEREI-REZEPTE
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (76, 7);   -- Karpfensushi (Bessere Köder)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (77, 43);  -- Escargot (Bessere Angelrute)

-- GEMÜSE-REZEPTE
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (95, 2);   -- Gemüseeintopf (Schnelleres Wachstum)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (96, 49);  -- Parsnip Soup (Wassersparen)

-- LETZTE ZUORDNUNGEN
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (97, 13);  -- Kürbiskuchen (Bessere Qualität)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (98, 11);  -- Kürbissuppe (Doppelte Ernte)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (99, 14);  -- Rübeneintopf (Resistenz)
INSERT INTO A_loesen_aus (BuffID, RezeptID) VALUES (100, 51); -- Red Plate (Ultimativer Buff)


-- HEIRATSBARE BEWOHNER UND IHRE LIEBLINGSREZEPTE
-- Abigail (ID 1)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (21, 1);   -- Abigail liebt Käsekuchen
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (22, 1);   -- Abigail liebt Schokoladenkuchen
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (46, 1);   -- Abigail liebt Eis

-- Alex (ID 2)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (54, 2);   -- Alex liebt Spaghetti
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (45, 2);   -- Alex liebt Hashbrowns

-- Elliott (ID 3)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (17, 3);   -- Elliott liebt Käsefondue
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (18, 3);   -- Elliott liebt Forelle am Wein

-- Emily (ID 4)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (27, 4);   -- Emily liebt Tee
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (9, 4);    -- Emily liebt Tom Kha Suppe

-- Haley (ID 5)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (46, 5);   -- Haley liebt Eis
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (24, 5);   -- Haley liebt Blaubeertorte

-- Harvey (ID 6)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (26, 6);   -- Harvey liebt Kaffee
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (28, 6);   -- Harvey liebt Bier

-- Leah (ID 7)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (39, 7);   -- Leah liebt Survival Burger
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (49, 7);   -- Leah liebt Parsnip Soup

-- Maru (ID 8)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (26, 8);   -- Maru liebt Kaffee
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (35, 8);   -- Maru liebt Dish O The Sea

-- Penny (ID 9)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (51, 9);   -- Penny liebt Red Plate
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (19, 9);   -- Penny liebt Plumpudding

-- Sam (ID 10)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (54, 10);  -- Sam liebt Spaghetti
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (45, 10);  -- Sam liebt Hashbrowns

-- Sebastian (ID 11)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (26, 11);  -- Sebastian liebt Kaffee
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (28, 11);  -- Sebastian liebt Bier

-- Shane (ID 12)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (28, 12);  -- Shane liebt Bier
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (45, 12);  -- Shane liebt Hashbrowns

-- NICHT-HEIRATSBARE BEWOHNER
-- Caroline (ID 13)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (27, 13);  -- Caroline liebt Tee

-- Clint (ID 14)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (28, 14);  -- Clint liebt Bier

-- Demetrius (ID 15)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (39, 15);  -- Demetrius liebt Survival Burger

-- Evelyn (ID 16)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (13, 16);  -- Evelyn liebt Kürbiskuchen

-- George (ID 17)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (13, 17);  -- George liebt Kürbiskuchen

-- Gus (ID 18)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (28, 18);  -- Gus liebt Bier

-- Jas (ID 19)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (46, 19);  -- Jas liebt Eis

-- Jodi (ID 20)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (54, 20);  -- Jodi liebt Spaghetti

-- Kent (ID 21)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (15, 21);  -- Kent liebt Super-Mahlzeit

-- Lewis (ID 22)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (28, 22);  -- Lewis liebt Bier

-- Linus (ID 23)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (39, 23);  -- Linus liebt Survival Burger

-- Marnie (ID 24)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (28, 24);  -- Marnie liebt Bier

-- Pam (ID 25)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (28, 25);  -- Pam liebt Bier

-- Pierre (ID 26)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (28, 26);  -- Pierre liebt Bier

-- Robin (ID 27)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (26, 27);  -- Robin liebt Kaffee

-- Sandy (ID 28)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (27, 28);  -- Sandy liebt Tee

-- Vincent (ID 29)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (46, 29);  -- Vincent liebt Eis

-- Willy (ID 30)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (28, 30);  -- Willy liebt Bier

-- Wizard (ID 31)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (27, 31);  -- Wizard liebt Tee (angenommen)

-- Leo (ID 32)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (46, 32);  -- Leo liebt Eis

-- Birdie (ID 33)
INSERT INTO A_liebt (RezeptID, BewohnerID) VALUES (27, 33);  -- Birdie liebt Tee


-- EINFACHE REZEPTE
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (1, 27);   -- Gebratene Pilze braucht Pilze (ID 27)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (2, 3);    -- Gemüseeintopf braucht Kartoffel (ID 3)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (2, 6);    -- Gemüseeintopf braucht Rübe (ID 6)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (3, 3);    -- Omelett braucht Kartoffel (ID 3)

-- FRÜHLINGS-REZEPTE
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (5, 3);    -- Frühlingsrolle braucht Kartoffel
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (5, 9);    -- Frühlingsrolle braucht Tulpe

-- SOMMER-REZEPTE
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (6, 12);   -- Tortilla braucht Mais (ID 12)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (8, 12);   -- Wurzelgemüseteller braucht Mais
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (9, 14);   -- Tom Kha Suppe braucht Melone (ID 14)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (10, 8);   -- Pfannkuchen braucht Erdbeere (ID 8)

-- HERBST-REZEPTE
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (11, 23);  -- Kürbissuppe braucht Kürbis (ID 23)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (13, 23);  -- Kürbiskuchen braucht Kürbis
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (14, 28);  -- Rübeneintopf braucht Rübe (Herbst) (ID 28)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (15, 21);  -- Super-Mahlzeit braucht Amaranth (ID 21)

-- WINTER-REZEPTE
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (19, 39);  -- Plumpudding braucht Kristallfrucht (ID 39)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (20, 3);   -- Rosmarinkartoffeln braucht Kartoffel

-- KUCHEN & DESSERTS
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (21, 8);   -- Käsekuchen braucht Erdbeere
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (22, 11);  -- Schokoladenkuchen braucht Blaubeere
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (23, 5);   -- Rhabarberkuchen braucht Rhabarber (ID 5)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (24, 11);  -- Blaubeertorte braucht Blaubeere
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (25, 36);  -- Kokoskuchen braucht Ananas (ID 36)

-- GETRÄNKE
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (26, 32);  -- Kaffee braucht Kaffeebohne (ID 32)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (27, 9);   -- Tee braucht Tulpe
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (28, 34);  -- Bier braucht Hopfen (ID 34)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (29, 8);   -- Mead braucht Erdbeere
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (30, 11);  -- Saft braucht Blaubeere

-- BUFF-REZEPTE
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (31, 23);  -- Kürbis-Suppe braucht Kürbis
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (32, 23);  -- Lobster Bisque braucht Kürbis
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (33, 23);  -- Maple Bar braucht Kürbis
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (34, 3);   -- Miners Treat braucht Kartoffel
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (35, 12);  -- Dish O The Sea braucht Mais
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (36, 12);  -- Fried Eel braucht Mais
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (37, 14);  -- Spicy Eel braucht Melone
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (38, 25);  -- Eggplant Parm braucht Aubergine (ID 25)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (39, 21);  -- Survival Burger braucht Amaranth
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (40, 3);   -- Farmers Lunch braucht Kartoffel

-- WEITERE REZEPTE
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (41, 24);  -- Cranberry Candy braucht Cranberry (ID 24)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (42, 12);  -- Crispy Bass braucht Mais
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (43, 27);  -- Escargot braucht Pilze
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (44, 12);  -- Fish Taco braucht Mais
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (45, 3);   -- Hashbrowns braucht Kartoffel
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (46, 8);   -- Ice Cream braucht Erdbeere
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (47, 12);  -- Maki Roll braucht Mais
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (48, 27);  -- Pale Broth braucht Pilze
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (49, 4);   -- Parsnip Soup braucht Rettich (ID 4)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (50, 19);  -- Pizza braucht Tomate (ID 19)

-- LETZTE REZEPTE
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (51, 11);  -- Red Plate braucht Blaubeere
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (52, 5);   -- Rhubarb Pie braucht Rhabarber
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (53, 12);  -- Salmon Dinner braucht Mais
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (54, 19);  -- Spaghetti braucht Tomate
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (55, 15);  -- Stir Fry braucht Pfeffer (ID 15)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (56, 12);  -- Stuffing braucht Mais
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (57, 32);  -- Triple Shot Espresso braucht Kaffeebohne

-- MEHRFACH-ZUTATEN (ein Rezept kann mehrere Zutaten brauchen)
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (11, 4);   -- Kürbissuppe zusätzlich Rettich
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (13, 8);   -- Kürbiskuchen zusätzlich Erdbeere
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (15, 12);  -- Super-Mahlzeit zusätzlich Mais
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (21, 11);  -- Käsekuchen zusätzlich Blaubeere
INSERT INTO A_braucht (RezeptID, FruchtID) VALUES (40, 12);  -- Farmers Lunch zusätzlich Mais


commit;