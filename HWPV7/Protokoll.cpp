
#include <vector>
#include <fstream>
#include <iostream>
#include <b15f/b15f.h>


void bearbeitenInput(bool IchBinLinksNichtRechts, std::string input);                 
std::vector<bool> binaerVerwandlung(char i);
std::vector<bool> binaerVerwandlung(uint8_t i);
void schreibeDatei();
void sendeWerte(bool IchBinLinksNichtRechts, char i);
void sendeWerte(bool IchBinLinksNichtRechts, uint8_t i);
void preSendenTeilung(bool IchBinLinksNichtRechts, std::vector<bool> binaer);
void setzeHexHex(uint8_t hex);
void lesenOutput(bool IchBinLinksNichtRechts);
void debugAusgabe(std::vector<bool> eingabe);
void debugAusgabe(uint8_t hex);
bool Handschlag();
uint8_t reversi(bool IchSENDELinksUndNichtRechts, uint8_t hex);
uint8_t entbinaerung(std::vector<bool> rueckwaerts);
void initPins();
void UEBERPRUEFUNGSAUSGABE(int i, uint8_t j);
void UEBERPRUEFUNGSAUSGABE(int i, std::vector<bool> j);
void UEBERPRUEFUNGSAUSGABE(int i, char j);
void UEBERPRUEFUNGSAUSGABE(int i);


void sende2Bit(uint8_t senden, bool SendenLinks);
void sende2BitREVERSE(uint8_t sendenReverse, bool SendenLinks);
void empfange4Bit();
bool pruefe3Bit();
uint8_t FEHLER_PIN_SENDEN;



//g++ -I/home/menetekel/b15f/control/src/drv -L/home/menetekel/b15f/control/src/drv Protokoll.cpp -o main && echo blablabla | ./main
//g++ Protokoll.cpp -lb15fdrv -o main && echo irgendwas | ./main
//scp Protokoll.cpp agoebel1@141.57.6.162:/home/agoebel1/Dokumente



//? kompilierbefehl ^ achtung, immer bibs mit angeben, -I ist includes und -L libraries. wenn man auf play drückt machts das automatisch, ohne befehl.
//! obere und untere bits mit | bitweise aufaddieren auf was vorher da ist, XOR???
//! idee ist clock als bitflip zu interpretieren. 2 leitungen für ist ok, sende so lange 0 bis fehler, dann 1, dann interrupt und neu das paket senden.

//? LinksRechts, 1 ist LINKS, 0 ist RECHTS. 0000 1111 : 0000 ist LINKS, 1111 ist RECHTS.
//! FEHLER PIN MUSS WIeDER RESETTET WERDEN WENN FEHLER BEHOBEN!!!!!!
//TODO ack senden bevor beide senden!
//TODO zurück umwandeln von binär und ASCII dabei die 9. stelle der 0 oder eins eventuell nochmal prüfen und DANN ggf umdrehen nur um sicher zu gehen
//TODO fehlerhafte blöcke nicht mit ins ende schreiben
//TODO mit logicanalyzer beweisen das es fullduplex synchron ist
//TODO geschw. vergleichen mit netcat, dazu entweder time nutzen oder oszi magie
//TODO testen ob ohne delay_ms funktioniert weil delay doof ist aus irgendeinem grund
//TODO ggf wechselbit einbauen falls randomisierte zeichen sowas wie 0000 1111 als folge haben, wo ja im protokoll es als 0000 1111 1111 0000 gesendet wird, was evtl nicht so schlau ist

std::vector<bool> debugSammel;
std::vector<bool> uebertragung;
std::vector<bool> dieGanzeMSGinBinaer; 
uint8_t letztesWortSenden;
uint8_t letztesWortEmpfangen;
std::vector<bool> empfangeneDatenKomplett;
int DELAY_B15F = 64;

bool SendeLinksEmpfangeRechts; //links DDRA senden: 0xF0 rechts empfangen

B15F& drv = B15F::getInstance();  

//? DDRA ist data direction
int main(){                                           
    std::string input;                                
    drv.setRegister(&DDRA, 0x00);  //? beide sind anfangs empfänger
    SendeLinksEmpfangeRechts = Handschlag(); //rechts links schwäche endgegner
    initPins();
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
        dieGanzeMSGinBinaer.push_back(0); //macht das aller 8 bits eine weitere 0 kommt zum aufteilen dann da unten weil ich ja immer 3 bit sende
        
        }

        bool fertig = false;

        for(int i = 0; i < dieGanzeMSGinBinaer.size(); i+=3){

            if(i + 2 >= dieGanzeMSGinBinaer.size()) break;

            do {

            letztesWortSenden = dieGanzeMSGinBinaer[i] << 2 | dieGanzeMSGinBinaer[i+1] << 1 | dieGanzeMSGinBinaer[i+2];

            UEBERPRUEFUNGSAUSGABE(1, letztesWortSenden);
            sende2Bit(letztesWortSenden, SendeLinksEmpfangeRechts); 
            drv.delay_ms(DELAY_B15F); 

            UEBERPRUEFUNGSAUSGABE(4);
            empfange4Bit(); 
            drv.delay_ms(DELAY_B15F);

            UEBERPRUEFUNGSAUSGABE(3, letztesWortSenden);
            sende2BitREVERSE(letztesWortSenden, SendeLinksEmpfangeRechts);        
            drv.delay_ms(DELAY_B15F);

            UEBERPRUEFUNGSAUSGABE(4, letztesWortSenden);
            fertig = pruefe3Bit();
            drv.delay_ms(DELAY_B15F);   
            if(!fertig) { UEBERPRUEFUNGSAUSGABE(5); }
        
            } while(!fertig);
        }
    }
    
    bool fehler = false;
    int zaehler = 0;
    int gottloserZaehler = 0;
    do {
        
    letztesWortSenden = 0x00;
    UEBERPRUEFUNGSAUSGABE(1, letztesWortSenden);
    sende2Bit(letztesWortSenden, SendeLinksEmpfangeRechts);
    drv.delay_ms(DELAY_B15F); 

    UEBERPRUEFUNGSAUSGABE(4);
    empfange4Bit();        
    drv.delay_ms(DELAY_B15F);

    UEBERPRUEFUNGSAUSGABE(3, letztesWortSenden); 
    sende2Bit(letztesWortSenden, SendeLinksEmpfangeRechts);                  
    drv.delay_ms(DELAY_B15F);

    UEBERPRUEFUNGSAUSGABE(4, letztesWortSenden);
    fehler = pruefe3Bit();
    drv.delay_ms(DELAY_B15F);     

    if(!(letztesWortSenden == 0x00 && letztesWortEmpfangen == 0x00)) {gottloserZaehler = 0;} 
    if(letztesWortSenden == 0x00 && letztesWortEmpfangen == 0x00 && gottloserZaehler == 1) {gottloserZaehler = 2;} 
    if(letztesWortSenden == 0x00 && letztesWortEmpfangen == 0x00 && gottloserZaehler == 0) {gottloserZaehler = 1;}       
    } while(letztesWortSenden == 0x00 && letztesWortEmpfangen == 0x00 && gottloserZaehler == 2); 

    schreibeDatei();
}

void initPins(){
    FEHLER_PIN_SENDEN = SendeLinksEmpfangeRechts ? 0x80 : 0x08;
}



bool pruefe3Bit(){
    uint8_t empfangeneDaten = drv.getRegister(&PINA);
    std::vector<bool> temp;
    if(SendeLinksEmpfangeRechts) {
        empfangeneDaten = empfangeneDaten & 0x07;            
    } else {
        empfangeneDaten = empfangeneDaten & 0x70;
        empfangeneDaten = empfangeneDaten >> 4;          
    } 
    if(empfangeneDaten == (letztesWortEmpfangen ^ 0x07)){
        return false;
    } else {
        drv.setRegister(&PORTA, FEHLER_PIN_SENDEN);
        drv.delay_ms(DELAY_B15F);
        return true;
    }

}

void empfange4Bit(){
    uint8_t empfangeneDaten = drv.getRegister(&PINA); 
    UEBERPRUEFUNGSAUSGABE(2, empfangeneDaten);   
    std::vector<bool> temp;
    if(SendeLinksEmpfangeRechts) {
        empfangeneDaten = empfangeneDaten & 0x07;
        temp = binaerVerwandlung(empfangeneDaten);       
    } else {
        empfangeneDaten = empfangeneDaten & 0x70;
        empfangeneDaten = empfangeneDaten >> 4;
        temp = binaerVerwandlung(empfangeneDaten);
          
    }
    letztesWortEmpfangen = empfangeneDaten;
    empfangeneDatenKomplett.push_back(temp[5]);
    empfangeneDatenKomplett.push_back(temp[6]);
    empfangeneDatenKomplett.push_back(temp[7]);  
}

void sende2BitREVERSE(uint8_t sendenReverse, bool SendenLinks){
    if(SendenLinks){
        // LINKS: invertiere die oberen 4 Bits (0x70)
       sendenReverse = sendenReverse ^ 0x70;  // XOR mit 0x70 invertiert Bits 4-7
    } else{                     
        // RECHTS: invertiere die unteren 4 Bits (0x07)
        sendenReverse = sendenReverse ^ 0x07;  // XOR mit 0x07 invertiert Bits 0-3
    }
    sende2Bit(sendenReverse, SendenLinks);
}

void sende2Bit(uint8_t senden, bool SendenLinks){
    if(SendenLinks){
        senden = (senden << 4) | 0x00;
    } else {
        senden = senden | 0x00;
    }
    setzeHexHex(senden);
}

void setzeHexHex(uint8_t hex){
    drv.setRegister(&PORTA, hex);    
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
    for(bool i : empfangeneDatenKomplett){
        auswurf << (i ? "1" : "0");
    }
    std::vector<bool> test;
    for(int i = 0; i<empfangeneDatenKomplett.size(); i++){
        if(!(i==0) && i % 9) { continue; }
        //!!!!!
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

uint8_t entbinaerung(std::vector<bool> rueckwaerts){
     uint8_t result = 0;
    for(int i = 0; i < 8; i++) {
        result = (result << 1) | rueckwaerts[i];  // MSB first
    }
    return result;
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
 */
void UEBERPRUEFUNGSAUSGABE(int i){
    switch(i){
        case 1: std::cerr << "Handshake..." << std::endl;
        break;
        case 2: std::cerr << "Ich bin Master! dh ich sende links und empfange rechts" << std::endl;
        break;
        case 3: std::cerr << "Ich bin Slave! dh ich sende rechts und empfange links" << std::endl;
        break;
        case 4: std::cerr << "Empfange..." << std::endl;
        break;
        case 5: std::cerr << "Fehler! Es wird erneut gesendet" << std::endl;
        break;
        default: std::cerr << "default switch case, fehler" << std::endl;
        break;
    }
}
/**
 * 1: Sende ZWEITE VARIABLE
 * 2: Empfange... (obsolet, ändern)
 * 3: Sende Reversi von ZWEITE VARIABLE
 * 4: Ueberpruefe Reversi von ZWEITE VARIABLE
 */
void UEBERPRUEFUNGSAUSGABE(int i, uint8_t j){
    switch(i){
        case 1: std::cerr << "Sende "; debugAusgabe(j);
        break;
        case 2: std::cerr << "Empfange ..."; debugAusgabe(j);
        break;
        case 3: std::cerr << "Sende Reversi von "; debugAusgabe(j);
        break;
        case 4: std::cerr << "Ueberpruefe Reversi von "; debugAusgabe(j);
        break;
        default: std::cerr << "default switch case, fehler" << std::endl;
        break;
    }
}
/**
 * 1: Sende ZWEITE VARIABLE
 * 2: Empfange... (obsolet, ändern)
 * 3: Sende Reversi von ZWEITE VARIABLE
 * 4: Ueberpruefe Reversi von ZWEITE VARIABLE
 */
void UEBERPRUEFUNGSAUSGABE(int i, std::vector<bool> j){
    switch(i){
        case 1: std::cerr << "Sende "; debugAusgabe(j);
        break;
        case 2: std::cerr << "Empfange ..." << std::endl;
        break;
        case 3: std::cerr << "Sende Reversi von "; debugAusgabe(j);
        break;
        case 4: std::cerr << "Ueberpruefe Reversi von "; debugAusgabe(j);
        break;
        default: std::cerr << "default switch case, fehler" << std::endl;
        break;
    }
}
/**
 * 1: Sende ZWEITE VARIABLE
 * 2: Empfange... (obsolet, ändern)
 * 3: Sende Reversi von ZWEITE VARIABLE
 * 4: Ueberpruefe Reversi von ZWEITE VARIABLE
 */
void UEBERPRUEFUNGSAUSGABE(int i, char j){
    switch(i){
        case 1: std::cerr << "Sende "; debugAusgabe(j);
        break;
        case 2: std::cerr << "Empfange ..." << std::endl;
        break;
        case 3: std::cerr << "Sende Reversi von "; debugAusgabe(j);
        break;
        case 4: std::cerr << "Ueberpruefe Reversi von "; debugAusgabe(j);
        break;
        default: std::cerr << "default switch case, fehler" << std::endl;
        break;
    }
}
