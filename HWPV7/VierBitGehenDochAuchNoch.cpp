#include <vector>
#include <fstream>
#include <iostream>
#include <b15f/b15f.h>


bool Handschlag();
void wartenAufACK();
std::vector<bool> binaerVerwandlung(uint8_t i);
void schreibeDatei();
void setzeHexHex(uint8_t hex);
void sende4Bit(uint8_t senden);
void sende4BitREVERSE(uint8_t sendenReverse);
uint8_t empfange4Bit();
void pruefe3Bit();
std::string entbinaerung(std::vector<bool> rueckwaerts);

std::vector<bool> dieGanzeMSGinBinaer; 
uint8_t letztesWortSenden;
uint8_t letztesWortEmpfangen;
std::vector<bool> empfangeneDatenKomplett;
uint8_t ACK = 0x0F;
int endeCounter = 0;


bool SendeLinksEmpfangeRechts; //links DDRA senden: 0xF0 rechts empfangen

B15F& drv = B15F::getInstance();  

//? DDRA ist data direction
int main(){                                           
    std::string input;                                
    drv.setRegister(&DDRA, 0x00);  //? beide sind anfangs empfänger
    SendeLinksEmpfangeRechts = Handschlag(); //rechts links schwäche endgegner

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

        uint8_t wortA, wortB;

        for(int i = 0; i < dieGanzeMSGinBinaer.size(); i+=4){
            if(i + 3 >= dieGanzeMSGinBinaer.size()) break;
            letztesWortSenden = dieGanzeMSGinBinaer[i] << 3 | dieGanzeMSGinBinaer[i+1] << 2 | dieGanzeMSGinBinaer[i+2] << 1 | dieGanzeMSGinBinaer[i+3];
             
            do{ sende4Bit(letztesWortSenden);
            wortA = empfange4Bit();
            sende4BitREVERSE(letztesWortSenden);
            wortB = empfange4Bit();
            
            } while(wortA != (-wortB))

        }

    std::cerr << "und hier die nachricht:" << std::endl;
    std::cerr << entbinaerung(empfangeneDatenKomplett) << std::endl;

    drv.delay_ms(256);
    drv.setRegister(&PORTA, 0x00); //ausmachen :)
    schreibeDatei();
}

}

//gibt 1 zurück wenn man schneller war, 0 wenn man langsamer war (MASTER SLAVE init)
bool Handschlag(){
    srand(time(0));
    drv.delay_ms(5000); //damit ich langsam beides drücken kann

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

void wartenAufACK(){
    drv.setRegister(&PORTA, 0x00);
    sende4Bit(ACK);
    uint8_t lesung;    
    do{      
        lesung = drv.getRegister(&PINA);
    }while(lesung != 0xFF);
    drv.delay_ms(16);
    setzeHexHex(0x00);
    if(!SendeLinksEmpfangeRechts) {drv.delay_ms(16); }
}

void sende4BitREVERSE(uint8_t sendenReverse){
    sendenReverse = sendenReverse ^ 0x0F;  
    sende4Bit(sendenReverse);
}

uint8_t empfange4Bit(){
    uint8_t empfangeneDaten = drv.getRegister(&PINA); 
    if(SendeLinksEmpfangeRechts) {
        empfangeneDaten = empfangeneDaten & 0x0F;
        return empfangeneDaten;       
    } else {
        empfangeneDaten = empfangeneDaten & 0xF0;
        empfangeneDaten = empfangeneDaten >> 4;
        return empfangeneDaten;        
          
    }

}

void sende4Bit(uint8_t senden){
    if(SendeLinksEmpfangeRechts){
        senden = (senden << 4);
    } 
    setzeHexHex(senden);
}


void setzeHexHex(uint8_t hex){
    uint8_t temp = drv.getRegister(&PORTA);
    
     if(SendeLinksEmpfangeRechts){
        temp |= (hex & 0xF0);  // Setze nur die Daten-Bits
    } else {
        temp |= (hex & 0x0F);  // Setze nur die Daten-Bits
    }
    drv.setRegister(&PORTA, temp);    
}

std::vector<bool> binaerVerwandlung(uint8_t i){
    std::vector<bool> binaer;

    for(int bit = 7; bit >= 0; bit--) {
        binaer.push_back((i >> bit) & 1);
    }
    return binaer;
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

void schreibeDatei(){
    std::ofstream auswurf("auswurf.txt");    
    
    std::vector<bool> test;
    for(int i = 0; i<empfangeneDatenKomplett.size(); i++){
        test.push_back(empfangeneDatenKomplett.at(i));
    }
    for(bool i : test){
        auswurf << (i ? "1" : "0");
    }

    
    auswurf << entbinaerung(empfangeneDatenKomplett);
    auswurf.close();
}