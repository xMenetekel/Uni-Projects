
#include <vector>
#include <fstream>
#include <iostream>
#include <b15f.h>


void bearbeitenInput(bool IchBinLinksNichtRechts, std::string input);                 
std::vector<bool> binaerVerwandlung(char i);
std::vector<bool> binaerVerwandlung(uint8_t i);
void schreibedatei();
void sendeWerte(bool IchBinLinksNichtRechts, char i);
void sendeWerte(bool IchBinLinksNichtRechts, uint8_t i);
void preSendenTeilung(bool IchBinLinksNichtRechts, std::vector<bool> binaer);
void setzeHexHex(bool IchSENDELinksUndNichtRechts, uint8_t hex);
void lesenOutput(bool IchBinLinksNichtRechts);
void debugAusgabe(std::vector<bool> eingabe);
void debugAusgabe(uint8_t hex);
bool Handschlag();
uint8_t reversi(bool IchSENDELinksUndNichtRechts, uint8_t hex);
uint8_t entbinaerung(std::vector<bool> rueckwaerts);

void sende3Bit(bool bitEins, bool bitZwei, bool bitDrei, bool SendenLinks);
void empfange4Bit();
void pruefe3Bit();



//g++ -I/home/menetekel/b15f/control/src/drv -L/home/menetekel/b15f/control/src/drv debuggingDaheim.cpp -o main && echo blablabla | ./main
//? kompilierbefehl ^ achtung, immer bibs mit angeben, -I ist includes und -L libraries. wenn man auf play drückt machts das automatisch, ohne befehl.
//! obere und untere bits mit | bitweise aufaddieren auf was vorher da ist, XOR???
//! idee ist clock als bitflip zu interpretieren. 2 leitungen für ist ok, sende so lange 0 bis fehler, dann 1, dann interrupt und neu das paket senden.

//? LinksRechts, 1 ist LINKS, 0 ist RECHTS. 0000 1111 : 0000 ist LINKS, 1111 ist RECHTS.


std::vector<bool> debugSammel;
std::vector<bool> uebertragung;
std::vector<bool> dieGanzeMSGinBinaer; 

bool SendeLinksEmpfangeRechts; //links DDRA senden: 0xF0 rechts empfangen

B15F& drv = B15F::getInstance(); //!testen im lab ob geht  

//? DDRA ist data direction
//! prüfung für wenn kein input dann automatisch empfänger seite ohne senderseite
int main(){                                           
    std::string input;                                
    drv.setRegister(&DDRA, 0x00);  //? beide sind anfangs empfänger
    SendeLinksEmpfangeRechts = Handschlag(); //rechts links schwäche endgegner

    std::string ALLES;
    while(std::getline(std::cin, input)){
        ALLES+= input;
    }

    for(char i : ALLES){
       std::vector<bool> temp = binaerVerwandlung(i);
       for(bool bit : temp){
        dieGanzeMSGinBinaer.push_back(bit);
       }
       dieGanzeMSGinBinaer.push_back(0); //macht das aller 8 bits eine weitere 0 kommt zum aufteilen dann da unten weil ich ja immer 3 bit sende
       
    }

    for(int i = 0; i < dieGanzeMSGinBinaer.size(); i+3){

        sende3Bit(dieGanzeMSGinBinaer[i], dieGanzeMSGinBinaer[i+1], dieGanzeMSGinBinaer[i+2], SendeLinksEmpfangeRechts);
        empfange4Bit();
        if(i % 6){ pruefe3Bit(); }
        drv.delay_ms(16);
    
    }


    while (std::getline(std::cin, input)) {           
        bearbeitenInput(SendeLinksEmpfangeRechts, input);
        lesenOutput(SendeLinksEmpfangeRechts);


        //!eventuell hier warte so und so viele sekunden für clk wechsel (b15f anpassen, 16ms laut juli/marie)
        drv.delay_ms(16);

    }
}

void sende3Bit(bool bitEins, bool bitZwei, bool bitDrei, bool SendenLinks){
    uint8_t dreiBitWort = bitEins << 2 | bitZwei << 1 | bitDrei;

    if(SendenLinks){
        dreiBitWort = (dreiBitWort << 4) | 0x00;
    } else {
        dreiBitWort = dreiBitWort | 0x00;
    }
}

void bearbeitenInput(bool IchBinLinksNichtRechts, std::string input){
    std::cout << input << std::endl;                  
    for (char i : input){
        sendeWerte(IchBinLinksNichtRechts, i);
    }

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

void schreibedatei(){
    std::ofstream auswurf("auswurf.txt");    
    for(bool i : debugSammel){
        auswurf << (i ? "1" : "0");
    }
    auswurf.close();
}

void sendeWerte(bool IchSENDELinksUndNichtRechts, char i){
    std::vector<bool> binaer = binaerVerwandlung(i);
    preSendenTeilung(IchSENDELinksUndNichtRechts, binaer);
}

void sendeWerte(bool IchSENDELinksUndNichtRechts, uint8_t i){
     std::vector<bool> binaer = binaerVerwandlung(i);
     preSendenTeilung(IchSENDELinksUndNichtRechts, binaer);
}

void preSendenTeilung(bool IchSENDELinksUndNichtRechts, std::vector<bool> binaer){
    uint8_t dreiBitWortEins = (binaer[0] << 2 | binaer[1] << 1 | binaer[2]);
    uint8_t dreiBitWortZwei = (binaer[3] << 2 | binaer[4] << 1 | binaer[5]);
    uint8_t dreiBitWortDrei = (binaer[6] << 2 | binaer[7] << 1 | 0);

   // debugAusgabe(binaer);

   if(IchSENDELinksUndNichtRechts){
        // Links: Bits in obere 4 Bits schieben
        dreiBitWortEins = (dreiBitWortEins << 4) | 0x00;
        dreiBitWortZwei = (dreiBitWortZwei << 4) | 0x00; 
        dreiBitWortDrei = (dreiBitWortDrei << 4) | 0x00;
    } else {
        // Rechts: Bits in untere 4 Bits
        dreiBitWortEins = dreiBitWortEins | 0x00;
        dreiBitWortZwei = dreiBitWortZwei | 0x00;
        dreiBitWortDrei = dreiBitWortDrei | 0x00;
    }
    setzeHexHex(IchSENDELinksUndNichtRechts, dreiBitWortEins);
    setzeHexHex(IchSENDELinksUndNichtRechts, dreiBitWortZwei);
    setzeHexHex(IchSENDELinksUndNichtRechts, dreiBitWortDrei);
    

}

void setzeHexHex(bool IchSENDELinksUndNichtRechts, uint8_t hex){

    drv.setRegister(&PORTA, hex);
    uint8_t umkehr = reversi(IchSENDELinksUndNichtRechts, hex);
    drv.setRegister(&PORTA, umkehr);


    std::vector<bool> temp = binaerVerwandlung(hex);
    //debugAusgabe(hex);
   // debugAusgabe(temp);  //grade geben sie beide das gleich aus yay
    for(bool bit : temp){
        debugSammel.push_back(bit);
    }
      //kjkj
}

   uint8_t reversi(bool IchSENDELinksUndNichtRechts, uint8_t hex){
    if(IchSENDELinksUndNichtRechts){
        // LINKS: invertiere die oberen 4 Bits (0xF0)
        return hex ^ 0xF0;  // XOR mit 0xF0 invertiert Bits 4-7
    } else{                     
        // RECHTS: invertiere die unteren 4 Bits (0x0F)
        return hex ^ 0x0F;  // XOR mit 0x0F invertiert Bits 0-3
    }
}

void lesenOutput(){
    schreibedatei();
}

//gibt 1 zurück wenn man schneller war, 0 wenn man langsamer war (MASTER SLAVE init)
bool Handschlag(){

    drv.delay_ms(100 + rand() % 500);

    if(drv.getRegister(&PINA) == 0x00){ //?der erste wird links
        drv.setRegister(&DDRA, 0xF0);
        drv.setRegister(&PORTA, 0xF0);
        return 1;
    }
    else {                              //? der zweite wird rechts
        drv.setRegister(&DDRA, 0x0F);
        drv.setRegister(&PORTA, 0x0F);
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