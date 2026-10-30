#include <vector>
#include <fstream>
#include <iostream>
#include <b15f/b15f.h>
#include <bitset>

#define ACK 0x07  // 3 = 0b111 = 0x07

bool SendeLinksEmpfangeRechts;
B15F& drv = B15F::getInstance();

uint8_t FEHLER_PIN_SENDEN;
uint8_t FEHLER_PIN_EMPFANGEN;
int FEHLER_PIN_SENDEN_ABER_ALS_INDEX;
int FEHLER_PIN_EMPFANGEN_ABER_ALS_INDEX;

void sende3Bit(uint8_t data,bool fehler);
uint8_t lese3Bit(bool &fehler);
bool Handschlag();
void wartenAufACK();
std::vector<bool> binaerVerwandlung(char i);
std::vector<bool> manageInput();
std::vector<bool> entferne9teStelleUndLetzteBits(std::vector<bool> empfangeneDatenKomplett);
std::string entbinaerung(std::vector<bool> rueckwaerts);
void initPins();

int main(){                                                                         
    drv.setRegister(&DDRA, 0x00);  //? beide sind anfangs empfänger
    //drv.setRegister(&DDRA, 0xF0);
    //drv.setRegister(&PORTA, 0xF0);
    //drv.delay_ms(10000);
    //return 0;
    SendeLinksEmpfangeRechts = Handschlag(); //rechts links schwäche endgegner
    //drv.delay_ms(10); //damit ich langsam beides drücken kann
    initPins();
    wartenAufACK();

    std::vector<bool> msgBin = manageInput();
    std::vector<bool> msgBinEmpfangen;

    bool fehler_ich = 0,fehler_du = 0;
    uint8_t kommendeDaten;
    size_t i = 0;
    while(i < msgBin.size()/3){
        if(!fehler_ich){
            kommendeDaten = msgBin[i*3] << 2 | msgBin[i*3 + 1] << 1 | msgBin[i*3+2];
            i++;
        }
        sende3Bit(kommendeDaten,fehler_du);
        uint8_t empfangneDatenA = lese3Bit(fehler_ich);
        sende3Bit(kommendeDaten ^ 0x7,fehler_du);
        uint8_t empfangneDatenB = lese3Bit(fehler_ich);

        fehler_du = (empfangneDatenA & (empfangneDatenB ^ 0x7)) != empfangneDatenA;

        if(!fehler_du){
            msgBinEmpfangen.push_back((empfangneDatenA >> 2) & 0x1);
            msgBinEmpfangen.push_back((empfangneDatenA >> 1) & 0x1);
            msgBinEmpfangen.push_back((empfangneDatenA) & 0x1);
        }

        if(empfangneDatenA == empfangneDatenB){
            struct timespec delay_timer_start, delay_timer_stop;
            clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &delay_timer_start);
            do{
                clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &delay_timer_stop);
            }while(delay_timer_stop.tv_nsec - delay_timer_start.tv_nsec >= 1000);//1ms
        }
    }
    std::cerr << std::endl << "Senden fertig" << std::endl;
    //fertig mit senden
    int exit_counter = 0;
    while(exit_counter < 10){
        sende3Bit(0x0,fehler_du);
        uint8_t empfangneDatenA = lese3Bit(fehler_ich);
        sende3Bit(0x1,fehler_du);
        uint8_t empfangneDatenB = lese3Bit(fehler_ich);

        fehler_du = (empfangneDatenA & (empfangneDatenB ^ 0x7)) != empfangneDatenA;

        if(!fehler_du){
            msgBinEmpfangen.push_back((empfangneDatenA >> 2) & 0x1);
            msgBinEmpfangen.push_back((empfangneDatenA >> 1) & 0x1);
            msgBinEmpfangen.push_back((empfangneDatenA) & 0x1);
        }

        if(empfangneDatenA == empfangneDatenB){
            struct timespec delay_timer_start, delay_timer_stop;
            clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &delay_timer_start);
            do{
                clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &delay_timer_stop);
            }while(delay_timer_stop.tv_nsec - delay_timer_start.tv_nsec >= 1000);//1ms
        }

        if(exit_counter <= 5){
            if(empfangneDatenA == 0 && empfangneDatenB == 1){
                exit_counter++;
            }else{
                exit_counter = 0;
            }
        }else{
            exit_counter++;
        }
    }

    //ausgabe
    std::cerr << std::endl << "Empfangen fertig:" << std::endl;
    std::cout << entbinaerung(entferne9teStelleUndLetzteBits(msgBinEmpfangen));
    std::cerr << std::endl << "fertig." << std::endl;
}

std::vector<bool> manageInput(){
    std::string input, alles;
    std::vector<bool> dieGanzeMSGinBinaer;
    while(std::getline(std::cin, input))alles+= input;

    if(!alles.empty()){
        for(char i : alles){
            std::vector<bool> temp = binaerVerwandlung(i);
            for(bool bit : temp){
                dieGanzeMSGinBinaer.push_back(bit);
            }        
            dieGanzeMSGinBinaer.push_back(0);
        }
    }
    return dieGanzeMSGinBinaer;
}

std::vector<bool> binaerVerwandlung(char i){
    std::vector<bool> binaer;
    for(int bit = 7; bit >= 0; bit--) {
        binaer.push_back((i >> bit) & 1);
    }
    return binaer;
}

void sende3Bit(uint8_t data,bool fehler){
    uint8_t temp;
    struct timespec delay_timer_start, delay_timer_stop;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &delay_timer_start);

    temp = data << (SendeLinksEmpfangeRechts)?(4):(0);
    temp |= (uint8_t)fehler << FEHLER_PIN_SENDEN_ABER_ALS_INDEX;
    drv.setRegister(&PORTA, temp);

    do{
        clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &delay_timer_stop);
    }while(delay_timer_stop.tv_nsec - delay_timer_start.tv_nsec >= 16000);//16ms

    std::cerr << std::bitset<8>(drv.getRegister(&PORTA)) << std::endl;
}

uint8_t lese3Bit(bool &fehler){
    uint8_t temp;
    struct timespec delay_timer_start, delay_timer_stop;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &delay_timer_start);

    temp = drv.getRegister(&PINA);
    fehler = 0x01 & (temp >> FEHLER_PIN_EMPFANGEN_ABER_ALS_INDEX);

    temp = 0b111 & (temp >> (SendeLinksEmpfangeRechts)?(0):(4));
    do{
        clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &delay_timer_stop);
    }while(delay_timer_stop.tv_nsec - delay_timer_start.tv_nsec >= 16000);//16ms

    return temp;
}

void initPins(){
    FEHLER_PIN_SENDEN = SendeLinksEmpfangeRechts ? 0x80 : 0x08;
    FEHLER_PIN_EMPFANGEN = SendeLinksEmpfangeRechts ? 0x08 : 0x80;
    FEHLER_PIN_SENDEN_ABER_ALS_INDEX = SendeLinksEmpfangeRechts ? 7 : 3;
    FEHLER_PIN_EMPFANGEN_ABER_ALS_INDEX = SendeLinksEmpfangeRechts ? 3 : 7;  
}

void wartenAufACK(){
    bool fehler;
    //drv.setRegister(&PORTA, 0x00);
    sende3Bit(ACK,false);
    uint8_t lesung;
    do{
        lesung = lese3Bit(fehler);
    }while(lesung != ACK);
    std::cerr << "Anne hat recht" << std::endl;
    drv.delay_ms(32);
    sende3Bit(0x0,false);
}

//gibt 1 zurück wenn man schneller war, 0 wenn man langsamer war (MASTER SLAVE init)
bool Handschlag(){
  //  srand(time(0)); //überbleibsel falls gleichzeitig starten
    drv.delay_ms(5000);
    if(drv.getRegister(&PINA) == 0x00){ //?der erste wird links
        drv.setRegister(&DDRA, 0xF0);
        drv.setRegister(&PORTA, 0xF0);
        std::cerr << "sende links empfange rechts" << std::endl;
        return 1;
    }
    else {                              //? der zweite wird rechts
        drv.setRegister(&DDRA, 0x0F);
        drv.setRegister(&PORTA, 0x0F);
        std::cerr << "sende rechts empfange links" << std::endl;
        return 0;
    }
}


std::vector<bool> entferne9teStelleUndLetzteBits(std::vector<bool> empfangeneDatenKomplett) {
    std::vector<bool> temp;

    for(int i = 0; i < empfangeneDatenKomplett.size(); i++) {
        if(i % 9 != 8) { 
            temp.push_back(empfangeneDatenKomplett.at(i));
        }
    }
    return temp;
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