#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

/*//! TODO
// [] Taster ordentlich programmieren
// [] Taster 3 programmieren
// [] Sleep Modus einfuegen
// [] wie Uhr von Rest des Codes trennen?
// [] Code strukturieren und Funktionen auslagern 
// */

volatile uint8_t sekunden = 0;
volatile uint8_t minuten = 0;
volatile uint8_t stunden = 0;

volatile uint8_t taster1_zustand = 0;
volatile uint8_t taster2_zustand = 0;
volatile uint8_t taster3_zustand = 0;

/*enum uhr_modi {
    MODUS_BLINKEN,
    MODUS_STUNDEN,
    MODUS_STUNDEN_PLUS,
    MODUS_STUNDEN_MINUS,
    MODUS_MINUTEN,
    MODUS_MINUTEN_PLUS,
    MODUS_MINUTEN_MINUS,
    MODUS_SPEICHERN,
    MODUS_SLEEP,
    MODUS_AN,
}*/

uint8_t minuten_auf_ports(uint8_t min);
void uhrfunktion();
void PWM();

void main() {
    DDRB = 0x3E; 
    DDRC = 0x3F;
    DDRD |= (1 << PD6) | (1 << PD5);

    /*PORTD |= 0x1C; //Taster Pins als Eingabe aktivieren
    EICRA |= (1 << ISC01);
    EICRA |= (1 << ISC11);

    EIMSK |= (1 << INT0); //Interrupt aktivieren
    EIMSK |= (1 << INT1);*/

    stunden = 0;
    minuten = 0;

    PORTB = ((PORTB & 0xC1) | ((stunden & 0x1F) << 1));
    PORTC =  minuten_auf_ports(minuten);

    uhrfunktion();
    PWM();
    
    //Hauptschleife
    while(1){
       /* switch(modus) {
            case(MODUS_BLINKEN):
            break;
            
            case(MODUS_STUNDEN):
            break;

            case(MODUS_STUNDEN_PLUS):
            break;

            case(MODUS_STUNDEN_MINUS):
            break;

            case(MODUS_MINUTEN):
            break;

            case(MODUS_MINUTEN_PLUS):
            break;

            case(MODUS_MINUTEN_MINUS):
            break;

            case(MODUS_SPEICHERN):
            break;

            case(MODUS_SLEEP):
            break;

            case(MODUS_AN):
            break;
        }*/
    }

    sei();
}

//Interrupt0 fuer Taster 1
/*ISR(INT0_vect) {
   
}

//Interrupt1 fuer Taster 2
ISR(INT1_vect) {
    
}*/


uint8_t minuten_auf_ports(uint8_t min) {
    uint8_t ergebnis = 0;
    
    // Bit 0 (LSB) vom Minutenwert geht an PC5 (Bit 5 in PORTC)
    if (min & 0x01) ergebnis |= (1 << 5);
    
    // Bit 1 vom Minutenwert geht an PC4 (Bit 4 in PORTC)
    if (min & 0x02) ergebnis |= (1 << 4);
    
    // Bit 2 vom Minutenwert geht an PC3 (Bit 3 in PORTC)
    if (min & 0x04) ergebnis |= (1 << 3);
    
    // Bit 3 vom Minutenwert geht an PC2 (Bit 2 in PORTC)
    if (min & 0x08) ergebnis |= (1 << 2);
    
    // Bit 4 vom Minutenwert geht an PC1 (Bit 1 in PORTC)
    if (min & 0x10) ergebnis |= (1 << 1);
    
    // Bit 5 (MSB) vom Minutenwert geht an PC0 (Bit 0 in PORTC)
    if (min & 0x20) ergebnis |= (1 << 0);
    
    return ergebnis;
}

void uhrfunktion() {
    /**
    / Externe Clock durch Uhrenquarz
    */

    //Asynchronen Modus aktivieren
    ASSR |= (1 << AS2); //Bit 5 in ASSR setzen -> externe crystal Clock

    //Konfiguration Update Busy Flags S. 150-151
    while (ASSR & ((1 << TCN2UB) | (1 << OCR2AUB) | (1 << TCR2AUB) | (1 << TCR2BUB)));

    //Clear Timer on Compare Match (CTC) S.145
    TCCR2A = (1 << WGM21); //Mode 2 CTC

    //Preskaler auf 1024 einstellen S.147
    TCCR2B = ((1 << CS22) | (1 << CS21) | (1 << CS20));

    //Compare Wert setzen
    OCR2A = 31;

    //Nochmal auf Update warten
    while (ASSR & ((1 << TCN2UB) | (1 << OCR2AUB) | (1 << TCR2AUB) | (1 << TCR2BUB)));

    //Interrupt konfigurieren TIMSK2
    TIMSK2 |= (1 << OCIE2A);
}

void PWM() {
    /**
    / PWM -> man setzt da Bits in das Speicherregister, was genau die Bits machen steht auf S 87-95
    / Das ist eine Fast PWM (zaehlt von 0-255) mit Prescaler 8
    */
    TCCR0A = (1 << COM0A1) | (1 << COM0B1) | (1 << WGM01) | (1 << WGM00);
    TCCR0B = (0 << WGM02) | (0 << CS02) | (1 << CS01) | (0 << CS00);

    OCR0A = 128;  // PD6 auf ca. 50% Helligkeit
    OCR0B = 128;
}

//Interrupt Routine fuer Zeitlogik
ISR(TIMER2_COMPA_vect) {
    sekunden ++;

    if(sekunden == 60) {
        sekunden = 0;
        minuten ++;

        if(minuten == 60) {
            minuten = 0;
            stunden ++;

            if(stunden >= 24) {
                stunden = 0;
            }
            //Stunden LEDs aktualisieren
            PORTB = ((PORTB & 0xC1) | ((stunden & 0x1F) << 1));
        }
        //Minuten LEDs aktualisieren
        PORTC =  minuten_auf_ports(minuten);
    }
}
