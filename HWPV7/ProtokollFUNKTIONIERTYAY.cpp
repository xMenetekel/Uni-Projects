
#include <vector>
#include <fstream>
#include <iostream>
#include <b15f/b15f.h>


void bearbeitenInput(std::string input);                 
std::vector<bool> binaerVerwandlung(char i);
std::vector<bool> binaerVerwandlung(uint8_t i);
void schreibeDatei();
void sendeWerte(char i);
void sendeWerte(uint8_t i);
void preSendenTeilung(std::vector<bool> binaer);
void setzeHexHex(uint8_t hex);
void lesenOutput();
void debugAusgabe(std::vector<bool> eingabe);
void debugAusgabe(uint8_t hex);
bool Handschlag();
uint8_t reversi(uint8_t hex);
std::string entbinaerung(std::vector<bool> rueckwaerts);
void initPins();
void UEBERPRUEFUNGSAUSGABE(int i, uint8_t j);
void UEBERPRUEFUNGSAUSGABE(int i);
void wartenAufACK();
std::vector<bool> neunteStelleEntfernen(std::vector<bool> booliboi);
void fehlerbehandlung();
bool fehlerPinIstOK();
void setzeNachrichtFertig();
void loescheFehlerPin();
void setzeFehlerPin();
void sende2Bit(uint8_t senden);
void sende4BitREVERSE(uint8_t sendenReverse);
void empfange2Bit();
void pruefe3Bit();

uint8_t FEHLER_PIN_SENDEN;
uint8_t ANTI_FEHLER_PIN_SENDEN;
uint8_t FEHLER_PIN_EMPFANGEN;
uint8_t ANTI_FEHLER_PIN_EMPFANGEN;
uint8_t NACHRICHT_FERTIG_PIN_SENDEN;
uint8_t NACHRICHT_FERTIG_PIN_EMPFANGEN;
int FEHLER_PIN_SENDEN_ABER_ALS_INDEX;
int FEHLER_PIN_EMPFANGEN_ABER_ALS_INDEX;



//g++ -I/home/menetekel/b15f/control/src/drv -L/home/menetekel/b15f/control/src/drv Protokoll.cpp -o main && echo blablabla | ./main
//g++ Protokoll.cpp -lb15fdrv -o main && echo irgendwas | ./main
//scp Protokoll.cpp agoebel1@141.57.6.162:/home/agoebel1/Dokumente
//das ist tisch 12 ^

//? kompilierbefehl ^ achtung, immer bibs mit angeben, -I ist includes und -L libraries. wenn man auf play drückt machts das automatisch, ohne befehl.
//! obere und untere bits mit | bitweise aufaddieren auf was vorher da ist, XOR???
//! idee ist clock als bitflip zu interpretieren. 2 leitungen für ist ok, sende so lange 0 bis fehler, dann 1, dann interrupt und neu das paket senden.

//? LinksRechts, 1 ist LINKS, 0 ist RECHTS. 0000 1111 : 0000 ist LINKS, 1111 ist RECHTS.


//TODO mit logicanalyzer beweisen das es fullduplex synchron ist
//TODO geschw. vergleichen mit netcat, dazu entweder time nutzen oder oszi magie



std::vector<bool> debugSammel;
std::vector<bool> uebertragung;
std::vector<bool> dieGanzeMSGinBinaer; 
uint8_t letztesWortSenden;
uint8_t letztesWortEmpfangen;
std::vector<bool> empfangeneDatenKomplett;
int DELAY_B15F = 64;
uint8_t ACK = 0x03;
int endeCounter = 0;

bool SendeLinksEmpfangeRechts; //links DDRA senden: 0xF0 rechts empfangen

B15F& drv = B15F::getInstance();  

//? DDRA ist data direction
int main(){                                           
    std::string input;                                
    drv.setRegister(&DDRA, 0x00);  //? beide sind anfangs empfänger
    SendeLinksEmpfangeRechts = Handschlag(); //rechts links schwäche endgegner

    initPins();

    wartenAufACK();
    std::string ALLES;
    while(std::getline(std::cin, input)){
        ALLES+= input;
    }
    if(!ALLES.empty()){
        for(char i : ALLES){
        std::vector<bool> temp = binaerVerwandlung(i);
            for(bool bit : temp){
                dieGanzeMSGinBinaer.push_back(bit);
            }        
        }

        for(int i = 0; i < dieGanzeMSGinBinaer.size(); i+=2){

            if(i + 1 >= dieGanzeMSGinBinaer.size()) break;

            letztesWortSenden = dieGanzeMSGinBinaer[i] << 1 | dieGanzeMSGinBinaer[i+1];

            do{                    
                UEBERPRUEFUNGSAUSGABE(1, letztesWortSenden);
                sende2Bit(letztesWortSenden); 
                drv.delay_ms(DELAY_B15F); 

                empfange2Bit(); 
                drv.delay_ms(DELAY_B15F);

                UEBERPRUEFUNGSAUSGABE(3, letztesWortSenden);
                sende4BitREVERSE(letztesWortSenden);        
                drv.delay_ms(DELAY_B15F);

                pruefe3Bit();
                
                drv.delay_ms(DELAY_B15F);   
            
            }while(!fehlerPinIstOK());
             
        }
        
    }
    
    setzeNachrichtFertig();
    sende2Bit(0x00);

    do {
        drv.delay_ms(DELAY_B15F); 
        empfange2Bit();        

        drv.delay_ms(DELAY_B15F);          
        drv.delay_ms(DELAY_B15F);

        pruefe3Bit();
        drv.delay_ms(DELAY_B15F);  
     
    } while((drv.getRegister(&PINA) & NACHRICHT_FERTIG_PIN_EMPFANGEN) != NACHRICHT_FERTIG_PIN_EMPFANGEN); 

    std::cerr << "und hier die nachricht:" << std::endl;
    std::cerr << entbinaerung(empfangeneDatenKomplett) << std::endl;

    drv.delay_ms(256);
    drv.setRegister(&PORTA, 0x00); //ausmachen :)
    schreibeDatei();
}

void setzeNachrichtFertig(){
    uint8_t port = drv.getRegister(&PORTA);
        port |= NACHRICHT_FERTIG_PIN_SENDEN;
        drv.setRegister(&PORTA, port);
        UEBERPRUEFUNGSAUSGABE(11);
}

bool fehlerPinIstOK(){
    uint8_t current = drv.getRegister(&PINA);
    if ((current &= FEHLER_PIN_EMPFANGEN) == FEHLER_PIN_EMPFANGEN){
        UEBERPRUEFUNGSAUSGABE(6);
        return false;
    } else {
        UEBERPRUEFUNGSAUSGABE(5);
        return true;
    }
}

void fehlerbehandlung(){
    empfangeneDatenKomplett.pop_back();
    empfangeneDatenKomplett.pop_back();
}

void initPins(){
    FEHLER_PIN_SENDEN = SendeLinksEmpfangeRechts ? 0x80 : 0x08;
    FEHLER_PIN_EMPFANGEN = SendeLinksEmpfangeRechts ? 0x08 : 0x80;
    FEHLER_PIN_SENDEN_ABER_ALS_INDEX = SendeLinksEmpfangeRechts ? 7 : 3;
    FEHLER_PIN_EMPFANGEN_ABER_ALS_INDEX = SendeLinksEmpfangeRechts ? 3 : 7;
    NACHRICHT_FERTIG_PIN_SENDEN = SendeLinksEmpfangeRechts ? 0x40 : 0x04;
    NACHRICHT_FERTIG_PIN_EMPFANGEN = SendeLinksEmpfangeRechts ? 0x04 : 0x40;    
}




void empfange2Bit(){
    uint8_t empfangeneDaten = drv.getRegister(&PINA); 
    UEBERPRUEFUNGSAUSGABE(2, empfangeneDaten);   
    std::vector<bool> temp;
    if(SendeLinksEmpfangeRechts) {
        empfangeneDaten = empfangeneDaten & 0x03;
        temp = binaerVerwandlung(empfangeneDaten);       
    } else {
        empfangeneDaten = empfangeneDaten & 0x30;
        empfangeneDaten = empfangeneDaten >> 4;
        temp = binaerVerwandlung(empfangeneDaten);
          
    }
    letztesWortEmpfangen = empfangeneDaten;
    empfangeneDatenKomplett.push_back(temp[6]);
    empfangeneDatenKomplett.push_back(temp[7]);  
}

void sende4BitREVERSE(uint8_t sendenReverse){
    sendenReverse = sendenReverse ^ 0x03;  
    sende2Bit(sendenReverse);
}

void sende2Bit(uint8_t senden){
    if(SendeLinksEmpfangeRechts){
        senden = (senden << 4);
    } 
    setzeHexHex(senden);
}


void setzeHexHex(uint8_t hex){
    uint8_t temp = drv.getRegister(&PORTA);
    
     if(SendeLinksEmpfangeRechts){
        // Maske: Behalte Fehler-Pin (0x80) und Fertig-Pin (0x40), Rest (0x30) für Daten
        temp &= 0xC0;  // Behalte nur die Control-Pins
        temp |= (hex & 0xF0);  // Setze nur die Daten-Bits
    } else {
        // Maske: Behalte Fehler-Pin (0x08) und Fertig-Pin (0x04), Rest (0x03) für Daten
        temp &= 0x0C;  // Behalte nur die Control-Pins
        temp |= (hex & 0x0F);  // Setze nur die Daten-Bits
    }
    drv.setRegister(&PORTA, temp);    
}

void pruefe3Bit(){
    uint8_t empfangeneDaten = drv.getRegister(&PINA);
    if((empfangeneDaten & NACHRICHT_FERTIG_PIN_EMPFANGEN) == NACHRICHT_FERTIG_PIN_EMPFANGEN) { UEBERPRUEFUNGSAUSGABE(10); return; }
    if(SendeLinksEmpfangeRechts) {
        empfangeneDaten = empfangeneDaten & 0x03;       
    } else {
        empfangeneDaten = empfangeneDaten & 0x30;
        empfangeneDaten = empfangeneDaten >> 4;          
    }
     
    // Vergleich: empfangeneDaten erwartet das invertierte letztesWortEmpfangen (2 bit)
    uint8_t erwartung = (~letztesWortEmpfangen) & 0x03;
    std::cerr << "Vergleich: empfangeneDaten=" << (int)empfangeneDaten 
          << " erwartung=" << (int)erwartung << std::endl;
    if(empfangeneDaten == erwartung){
        loescheFehlerPin();
        UEBERPRUEFUNGSAUSGABE(9);
    } else {
        setzeFehlerPin();
        fehlerbehandlung();
        UEBERPRUEFUNGSAUSGABE(8);
        drv.delay_ms(DELAY_B15F);
    }
}

void loescheFehlerPin(){
    uint8_t port = drv.getRegister(&PORTA);
    port&=~(1<<FEHLER_PIN_SENDEN_ABER_ALS_INDEX);
    drv.setRegister(&PORTA, port);

}
void setzeFehlerPin(){
    uint8_t port = drv.getRegister(&PORTA);
    port|=(1<<FEHLER_PIN_SENDEN_ABER_ALS_INDEX);
    drv.setRegister(&PORTA, port);
}

void wartenAufACK(){
    drv.setRegister(&PORTA, 0x00);
    sende2Bit(ACK);
    uint8_t lesung;    
    do{
        UEBERPRUEFUNGSAUSGABE(7);        
        lesung = drv.getRegister(&PINA);
        UEBERPRUEFUNGSAUSGABE(1, lesung);
    }while(lesung != 0x33);
    drv.delay_ms(DELAY_B15F);
    setzeHexHex(0x00);
    if(!SendeLinksEmpfangeRechts) {drv.delay_ms(DELAY_B15F / 2); }
}


std::vector<bool> binaerVerwandlung(char i){
    std::vector<bool> binaer;

    for(int bit = 7; bit >= 0; bit--) {
        binaer.push_back((i >> bit) & 1);
        uebertragung.push_back((i >> bit) & 1);
    }
    return binaer;
}

std::vector<bool> binaerVerwandlung(uint8_t i){
    std::vector<bool> binaer;

    for(int bit = 7; bit >= 0; bit--) {
        binaer.push_back((i >> bit) & 1);
        uebertragung.push_back((i >> bit) & 1);
    }
    return binaer;
}

void schreibeDatei(){
    std::ofstream auswurf("auswurf.txt");    
    
    std::vector<bool> test;
    for(int i = 0; i<empfangeneDatenKomplett.size(); i++){
        test.push_back(empfangeneDatenKomplett.at(i));
    }
    for(bool i : test){
        auswurf << (i ? "1" : "0");
    }

    auswurf.close();
}

//gibt 1 zurück wenn man schneller war, 0 wenn man langsamer war (MASTER SLAVE init)
bool Handschlag(){
    UEBERPRUEFUNGSAUSGABE(1);
    srand(time(0));
    drv.delay_ms(5000); //damit ich langsam beides drücken kann

    if(drv.getRegister(&PINA) == 0x00){ //?der erste wird links
        drv.setRegister(&DDRA, 0xF0);
        drv.setRegister(&PORTA, 0xF0);
        UEBERPRUEFUNGSAUSGABE(2);
        return 1;
    }
    else {                              //? der zweite wird rechts
        drv.setRegister(&DDRA, 0x0F);
        drv.setRegister(&PORTA, 0x0F);
        UEBERPRUEFUNGSAUSGABE(3);
        return 0;
    }
}

std::string entbinaerung(std::vector<bool> rueckwaerts){
    std::string nachricht;
    for(int i = 0; i < (rueckwaerts.size() / 8); i++) {
        uint8_t result = 0;
        for(int j = 0; j < 8; j++){
             uint8_t bit = rueckwaerts[i*8 + j] ? 1 : 0;
            result = (result << 1) | bit;  // MSB first
        }
        nachricht.push_back(static_cast<char>(result));
    }
    return nachricht;
}


//! _________________ kann man so lassen ab hier bzw debgging ______________________
//! ________________________________________________________________________________

void debugAusgabe(uint8_t hex){
    std::cout << std::bitset<8>(hex) << std::endl;
}

void debugAusgabe(std::vector<bool> eingabe){
    for(bool bit : eingabe){
        std::cout << bit;
    }
    std::cout << "\n";
}
/**
 * 1: Handshake Ausgabe
 * 2: Ich Bin Master
 * 3: Ich bin Slave
 * 4: Empfange...
 * 5: ALLES PALETTI
 * 6: NIX PALETTI
 * 7: Warten...
 * 8: Fehler gefunden :( Fehlerpin gesetzt
 * 9: Fehler behoben :)
 * 10: Nachricht ggü fertig :)
 * 11: eigene nachricht fertig :)
 */
void UEBERPRUEFUNGSAUSGABE(int i){
    switch(i){
        case 1: std::cerr << "Handshake..." << std::endl;
        break;
        case 2: std::cerr << "Ich bin LINKS! dh ich sende links und empfange rechts" << std::endl;
        break;
        case 3: std::cerr << "Ich bin RECHTS! dh ich sende rechts und empfange links" << std::endl;
        break;
        case 4: std::cerr << "Empfange..." << std::endl;
        break;
        case 5: std::cerr << "ALLES PALETTI, gegenüber hat keinen Fehler gefunden" << std::endl;
        break;
        case 6: std::cerr << "NIX PALETTI, gegenüber hat einen Fehler gefunden" << std::endl;
        break;
        case 7: std::cerr << "Warten..." << std::endl;
        break;
        case 8: std::cerr << "Fehler gefunden :( Fehlerpin gesetzt" << std::endl;
        break;
        case 9: std::cerr << "Fehler behoben! oder keiner war da. Fehlerpin entsetzt" << std::endl;
        break;
        case 10: std::cerr << "Nachricht von gegenüber fertig :)" << std::endl;
        break;
        case 11: std::cerr << "eigene Nachricht vollständig gesendet!" << std::endl;
        break;
        default: std::cerr << "default switch case, fehler" << std::endl;
        break;
    }
}
/**
 * 1: Sende ZWEITE VARIABLE
 * 2: Empfange... ZWEITE VARIABLE
 * 3: !Sende ZWEITE VARIABLE
 * 4: leer
 * 5: !Empfange ZWEITE VARIABLE
 */
void UEBERPRUEFUNGSAUSGABE(int i, uint8_t j){
    switch(i){
        case 1: std::cerr << "Sende: "; debugAusgabe(j);
        break;
        case 2: std::cerr << "Empfange: "; debugAusgabe(j);
        break;
        case 3: std::cerr << "!Sende: "; debugAusgabe(j);
        break;
        case 4: std::cerr << "DEBUG"; debugAusgabe(j);
        break;
        case 5: std::cerr << "!Empfange: "; debugAusgabe(j);
        break; 
        default: std::cerr << "default switch case, fehler" << std::endl;
        break;
    }
}

