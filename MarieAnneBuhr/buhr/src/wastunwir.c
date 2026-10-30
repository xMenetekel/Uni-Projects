#define F_CPU 1000000UL
#define FOSC 1000000UL // Clock Speed
#define BAUD 2400
#define MYUBRR FOSC/16/BAUD-1
#include <avr/interrupt.h>
#include <avr/io.h>
#include <stdbool.h>
#include <util/delay.h>
#include <avr/sleep.h>




typedef enum states{
    schlafmodus,
    wach_eingang,
    eins_anzeige,
    zwei_anzeige,
    drei_anzeige,
    sekundenanzeiger_knightrider,
    pre_stoppuhr,
    stoppuhr,
    zeit_stopp,
    stunden_stellen,
    minuten_stellen,
    pre_sleepmode,
    debug_mode,
    zeitstellen_debug
}status;


volatile int active_stopper = 0;
volatile bool hoch = true;
volatile char zeit[4];
volatile int gottloseCounter = 0;

volatile uint8_t seconds;
volatile uint8_t minutes;
volatile uint8_t hours;
volatile uint16_t overflow_counter; 
volatile uint8_t stopper;
volatile uint8_t stopperMinuten;
volatile status current_state;
volatile status next_state;
volatile uint8_t PRELL1 = 0;
volatile uint8_t knight = 1;
volatile uint8_t flaggeButton1 = 0;
volatile uint8_t flaggeButton2 = 0;
volatile uint8_t flaggeButton3 = 0;
volatile uint16_t schlimmeCounterVariable = 1;
volatile uint8_t eingangFlag = 0;
volatile uint8_t dummeFlag = 0;
volatile uint8_t zwischenvariable;

void USART_Init(unsigned int ubrr);
void PWMWerteAn();
void PWMWerteAus();
void allesAn();
void allesAus();
void ledClear();
void stopuhr_start(int button);
void clockIsClocking();
void countMinutes();
void countHours();
status button1_nextState(status state);
status button2_nextState(status state);
status button3_nextState(status state);
void stelle_minuten(int button);
void activeWach_Eingang();
bool pruefen();
void button1Aufruf();
void initialisiereWachAuf();
void button2Aufruf();
void button3Aufruf();
void einsAnzeigen();
void zweiAnzeigen();
void dreiAnzeigen();
void sekundenanzeigenUndKnightRiderAnzeigen();
void stopuhrFunktion(int button);
void stopperClear();
void stopperClock();
void state_Handler(status state, int button);
void wach();
void stelle_stunden(int button);
uint8_t pow(int a, int b);
void stopperClear();
void initialisiereWachAuf();
void wachAuf();
void schlafenlegen(int button);
void usart_senden(char* data);
void usart_senden_int(int zahl);
void usart_senden_einzelnes_zeichen(char data);
void zeitstellenDebug();
void PWMVOLL();

//prescaler teilt systemtaktfrequenz (????) bevor timer erreicht wird, sonst timer zu schnell

/*//! TODO

[x] Uhrenquarz auf 60 Sekunden, dann zählt Minuten hoch
[x] Wenn 60 Minuten, dann zählt Stunden hoch + Minuten Reset
[x] Bei Stunden (Port B) PB6 aus dem Bitvektor?? entfernen, damit das nicht mitzählt, weil wir den nicht ansprechen
[x] Wenn Stunden auf 24 sind, dann auch Reset auf 0x00
[x] Uhrenquarz ordentlich ansprechen / Takt vorgibt, prescaler, Zeitbasis
[-] Sleepmode einbauen bzw optimierung stromverbrauch
[x] tamagotchi menü 
[] RS232
[x] eventuell schauen wegen pwm und pull up widerstände weil so dunkel ist
[x] prellwert höher stellen
[x] button3 hat doofe zustandsübergänge
[x] überprüfen strom
[x] zeitmessung mit oszi
*/


/* //? weitere Notizen: 
    wir nutzen TCCR2, den "Spezialisten", danke deepseek, für Uhrenquarztimer und TCCR0 für pwm, das sind separierte dinge und das ist gut so
    a ist für PWM verantworltich also können wir auf register 0 bleiben

*/


void main(){
    
    
    DDRD|=(0<<PD2)|(0<<PD3)|(0<<PD4);
    PORTD|=(1<<PD2)|(1<<PD3)|(1<<PD4);

    allesAn();

    TCCR2B |= (1<<CS22);                //prescaler=128, wird bestimmt durch 101 der CS bits. hier CS21 = 0
    TCCR2B |= (1<<CS20);                //TCCR2 wird für uhrenquarztakte verwendet, TCCR0, 1 ist für interne systemtakte
	ASSR |= (1<<AS2);                   //schalded asynchronen timer 2 an
	while(ASSR & (( 1 << TCN2UB) | (1 << TCR2BUB) | ( 1 << TCR2AUB))){} //wartet bis 3 flags null sind bevor weiter geht für synchrones arbeiten
    PWMWerteAn();
    TCCR0A|=(1<<WGM01)|(1<<WGM00);      //wgm01 und 00 sind die fastPWM einstellungen, timer zählt von 0 bis 255 und wdht dann
    TCCR0A|=(1<<COM0A1)|(1<<COM0A0);    //com0a1 / a0 steuert verhalten von OC0A / PD6, Set OC0A on compare match
    TCCR0A|=(1<<COM0B1)|(1<<COM0B0);    //com0b1 / b0 steuert verhalten von OC0B / PD5, Set OC0B on compare match
    TCCR0B |= (1<<CS01)|(1<<CS00);      //clk I/O/64 (from prescaler) für die pwm
    DDRD|=(1<<PD6);                     //PD 6 wird als ausgang gesetzt für data direction registry
    DDRD|=(1<<PD5);                     //PD 5 wird als ausgang gesetzt für data direction registry
    TIMSK2|=(1<<TOIE2);                 //setzt den timeroverflow interrupt
    EIMSK|=(1<<INT1);                   //Interrupt 1 wird aktiviert (Button 2)
    EIMSK|=(1<<INT0);                   //Interrupt 0 wird aktiviert (Button 3)

                                        //Button 1
    EICRA|=(1<<ISC11)|(1<<ISC01);       //falling edge für beide buttons
    PCICR|=(1<<PCIE2);                  //setzt pinchange interrupt enable 
    PCMSK2|=(1<<PCINT20);               //Pin Change interrupt auf PD4 wird enabled
    
    SMCR|= (1<<SE);                     //macht sleepmode bit an aber glaube das hier halt sinnlos und das kann wahrscheinlicha uch unten stehen idk
    //set_sleep_mode(SLEEP_MODE_IDLE);
    //sleep_mode();

    sei();
   
    current_state = wach_eingang;

    while(1){
        if(current_state == schlafmodus){
            SMCR|=(1<<SM0)|(1<<SM1);   
            set_sleep_mode(SLEEP_MODE_PWR_SAVE);
            while(current_state == schlafmodus){
                sleep_mode();
            }
        }
        if(flaggeButton1) {button1Aufruf();}
        if(flaggeButton2) {button2Aufruf();}
        if(flaggeButton3) {button3Aufruf();}
        _delay_ms(20);
        schlimmeCounterVariable++;
        if(PRELL1 != 0)PRELL1--;
        state_Handler(current_state, 0);

    }
}

void PWMWerteAn()
{
    OCR0A = 10; // die beiden werte bestimmen helligkeit der PWM. 255 = 100%, 125 = ~50% PORT STUNDEN (B)
    OCR0B = 20; // die beiden werte bestimmen helligkeit der PWM. 255 = 100%, 125 = ~50% PORT MKINUTEN (C)
}

/*
    10 / 256 * 100 = 3,9%
    20 / 256 * 100 = 7,8%

*/

void PWMWerteAus(){
    OCR0A = 0;
    OCR0B = 0;
}

void PWMVOLL(){
    OCR0A = 255;
    OCR0B = 255;
}

void USART_Init(unsigned int ubrr){
    UBRR0H = (unsigned char)(ubrr>>8);
    UBRR0L = (unsigned char)ubrr;

    UCSR0B = (1<<RXEN0)|(1<<TXEN0);
    /* Set frame format: 8data, 2stop bit */
    UCSR0C = (1<<USBS0)|(3<<UCSZ00);
    }

void debugModus(){
    
    if(eingangFlag){
        USART_Init(MYUBRR);   
        eingangFlag = 0;
    }
    if(dummeFlag){
    usart_senden("Es ist ");
    usart_senden_int(hours);
    usart_senden(":");
    usart_senden_int(minutes);
    usart_senden(":");
    usart_senden_int(seconds);
    usart_senden("\n\r");
    dummeFlag = 0;
    }
    
      

}
void usart_senden_einzelnes_zeichen(char data){
    while(!(UCSR0A & (1<<UDRE0)));
    UDR0 = data;
}

void usart_senden_int(int value) {
    char ziffer_1 = (value/10) + '0';
    char ziffer_2 = (value % 10) + '0';
    usart_senden_einzelnes_zeichen(ziffer_1);
    usart_senden_einzelnes_zeichen(ziffer_2);
}

void usart_senden(char* data){
    char* sendbuf = data;
    while(*sendbuf){    
        while(!(UCSR0A & (1<<UDRE0)));
        UDR0 = *sendbuf++;
    }   
}


bool pruefen(){
    if(minutes == PORTC){
        return false;
    } else {
        return true;
    }
}

ISR(TIMER2_OVF_vect){  //timer interrupt
        clockIsClocking();    
        
        if(active_stopper == true) {
            stopperClock();
        }
       		
}

ISR(INT0_vect){ //Das ist Button 3, externer interrupt
    if(PRELL1 == 0){
        PRELL1 = 10;
        flaggeButton3 = 1;
    }
}
    
ISR(INT1_vect){ //Das ist Button 2, externer interrupt
      if(PRELL1 == 0){
        PRELL1 = 10;
        flaggeButton2 = 1;
    }
}

ISR(PCINT2_vect){ //Das muss Button 1 sein aber es heißt anders, T0, pin change interrupt
     if(current_state == schlafmodus){
        current_state = wach_eingang;
        allesAn();
        PWMWerteAn();
    } else {
        if(PRELL1 == 0){
            PRELL1 = 10;
            flaggeButton1 = 1;
        }
    }
}

void clockIsClocking(){
   if (seconds >= 59){
        seconds = 0;
        dummeFlag = 1;
        countMinutes();
    }
    else{
    seconds++;
    dummeFlag = 1;
    }
}

void stopperClock(){
    if(stopper >= 59){
        stopper = 0;
        stopperMinuten++;
        if(stopperMinuten >= 31){ //maximal 30 minuten kann man stoppuhren
            stopperMinuten = 0;
        }
    }
    else {
        stopper++;
    }
}

void countMinutes(){
    if (minutes >= 59){
        minutes = 0;
        countHours();
    }
    else{
    minutes++;
    }
}

void countHours(){
    if(hours >= 23){ 
        hours = 0;
    }
    else{
    hours++;
    }
}

void button1Aufruf(){   
    next_state = button1_nextState(current_state);
    initialisiereWachAuf();
    state_Handler(next_state, 1);
    flaggeButton1 = 0;
    current_state = next_state;
}

void initialisiereWachAuf(){
    if ((current_state == schlafmodus) && (next_state == wach_eingang))    {
        wachAuf();
    }
}

void button2Aufruf(){
    next_state = button2_nextState(current_state);
    initialisiereWachAuf();
    state_Handler(next_state, 2);
    flaggeButton2 = 0;
    current_state = next_state;
}

void button3Aufruf(){
    next_state = button3_nextState(current_state);
    initialisiereWachAuf();
    state_Handler(next_state, 3);
    flaggeButton3 = 0;
    current_state = next_state;
}

void activeWach_Eingang(){
    PORTC = minutes;
    PORTB = hours * 2; //weil wir ein pin nicht haben, alles >>
}

void state_Handler(status state, int button){ //! einfügen das wenn button == 0 muss aus manchen funktionen rausgesprungen werden
    switch(state){
        case wach_eingang: 
            wach();
        break;
        case eins_anzeige:
            einsAnzeigen();
        break;
        case zwei_anzeige:
            zweiAnzeigen();
        break;
        case drei_anzeige:
            dreiAnzeigen();
        break;
        case sekundenanzeiger_knightrider:
            sekundenanzeigenUndKnightRiderAnzeigen();
        break;
        case pre_stoppuhr:
            ledClear();
        break;
        case stoppuhr:
            stopuhr_start(button);
        break;
        case zeit_stopp:
        break;
        case stunden_stellen:
            stelle_stunden(button);
        break;
        case minuten_stellen:
            stelle_minuten(button);
        break;
        case pre_sleepmode:
            
        break;
        case schlafmodus:
           // schlafenlegen(button);            
        break;
        case debug_mode:
            debugModus();
        break;
        case zeitstellen_debug:
            
            zeitstellenDebug();
        default: 
        break;
    }
}

void zeitstellenDebug(){
    if(eingangFlag){ 
    usart_senden("Bitte Uhrzeit im Format HH:MM eingeben. Ohne Doppelpunkt. \r\nDrücke (vielleicht 2x) x um Zeiteinstellung zu beenden\r\n");
    eingangFlag = 0;
    }
    while(!(UCSR0A & (1<<RXC0)));
        zwischenvariable = UDR0;
        switch(zwischenvariable){
            case 'x': current_state = debug_mode;
            break;
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9': 
                debug_Eingabe(zwischenvariable);
            break;
            default: 
                usart_senden("Falsche Eingabe...\r\n");
            break;
        }  
}


void debug_Eingabe(uint8_t zwischenvariable){
    
    zeit[gottloseCounter] = zwischenvariable;
    gottloseCounter++;
        if(gottloseCounter == 4) {
            usart_senden(zeit + '\r\n');
            
            gottloseCounter = 0;
            current_state = debug_mode;
            int stunden = (zeit[0] - '0') * 10 + (zeit[1] - '0');
            int minuten = (zeit[2] - '0') * 10 + (zeit[3] - '0');
            hours = stunden;
            minutes = minuten;

        }
}

void wachAuf(){
    SMCR&=0x00;
    SMCR|=(1<<SE);
    set_sleep_mode(SLEEP_MODE_IDLE);
   // sleep_mode();
}

// idle für LEDs und powersave wenn LEDs aus
void schlafenlegen(int button){
   
    SMCR|=(1<<SM0)|(1<<SM1);   

    set_sleep_mode(SLEEP_MODE_PWR_SAVE);
    while(flaggeButton1 == 0 && flaggeButton2 == 0 && flaggeButton3 == 0){
        sleep_mode();
    }
    
}

void ledClear(){
    PORTB = 0;
    PORTC = 0;
}

void einsAnzeigen(){
    PORTB = 2;
    PORTC = 0;
}

void zweiAnzeigen(){
    PORTB = 6;
    PORTC = 0;
}

void dreiAnzeigen(){
    PORTB = 14;
    PORTC = 0;
}

void sekundenanzeigenUndKnightRiderAnzeigen(){
    stopperClear();
    if((schlimmeCounterVariable % 10) == 0){
        if (hoch){
            PORTB = pow(2, knight);
            knight++;
            if(knight == 6) {
                hoch = false;
            }
        } else {
            PORTB = pow(2,knight);
            knight--;
            if (knight == 0) {
                hoch = true;
            }
        }
    }       
    PORTC = seconds;
}

void stopuhrFunktion(int button){
    if(button == 1 && active_stopper == 0) {
        active_stopper = 1;
    }
    else if(button == 2 && active_stopper == 1) {
        active_stopper = 0;
    }
    else if(button == 2) {
        PORTC = 0;
        active_stopper = 0;
    }
    if (button == 3){
        stopperClear();
    }
}
void stopperClear(){
    ledClear();
    active_stopper = 0;
    stopper = 0;
    stopperMinuten = 0;
}

void wach(){
    if(pruefen()){
        activeWach_Eingang();
    }
}

void stopuhr_start(int button) {
    stopuhrFunktion(button);
    PORTC = stopper;
    PORTB = stopperMinuten * 2;
}

uint8_t pow(int a, int b) {
    if (b == 0) return 1;
    
    uint8_t result = 1;
    for (int i = 0; i < b; i++) {
        result = result * a;
    }
    return result;
}

void stelle_stunden(int button){
    if(button != 0){
        int t_hours = hours;
        if(button == 1){

            t_hours++;
        }
        else if(button == 3){

            t_hours--;
        }

        if(t_hours >= 24) {
            hours = 0;
        }
        else if(t_hours < 0) {
            hours = 23;
        }
        else {
            hours = t_hours;
        }
        PORTB = hours * 2;
    }
}

void stelle_minuten(int button){
    if(button != 0){
        int t_minutes = minutes;
        if(button == 1){
            t_minutes++;
        }
        else if(button == 3){
            t_minutes--;
        }

        if(t_minutes >= 59){
            minutes = 0;
        }
        else if(t_minutes < 0) {
            minutes = 59;
        }
        else {
            minutes = t_minutes;
        }
        
        PORTC = minutes;
    }
}


status button1_nextState(status state){  //PD4, 6, PCINT20
    switch(state){
        case schlafmodus:    
            allesAn();   
            PWMWerteAn();
            return wach_eingang;      
        case wach_eingang:
            return eins_anzeige;
        case eins_anzeige:
            return zwei_anzeige;
        case zwei_anzeige:
            return drei_anzeige;
        case drei_anzeige:
            return drei_anzeige; //?hier ausbauen, undefiniert
        case sekundenanzeiger_knightrider:
            return pre_stoppuhr;
        case stoppuhr:
            return stoppuhr; //schauen das es sich nicht doppelausführt
        case zeit_stopp:
            return stoppuhr; //!hier problem, später anschauen
        case stunden_stellen:
            return stunden_stellen; 
        case minuten_stellen:
            return minuten_stellen; 
        case pre_sleepmode:
            return wach_eingang;
        case debug_mode: 
            eingangFlag = 1;
            return zeitstellen_debug;
        case pre_stoppuhr:
            return stoppuhr;
        case zeitstellen_debug:
            return zeitstellen_debug;
        default: 
            return wach_eingang;
    }
}

status button2_nextState(status state){ //PD3, 
    switch(state){
        case schlafmodus:             
            return schlafmodus;
        case wach_eingang:
            return wach_eingang; //dopplung, schhauen was passiert
        case eins_anzeige:
            return sekundenanzeiger_knightrider;
        case zwei_anzeige:
            return stunden_stellen;
        case drei_anzeige:
            eingangFlag = 1;
            return debug_mode; //?ausbau, undefiniert
        case sekundenanzeiger_knightrider:
            return sekundenanzeiger_knightrider; //?unedfiniert
        case stoppuhr:
            return zeit_stopp; 
        case zeit_stopp:
            return zeit_stopp; //!eventuelle ändern weil zustandsdefinition doof
        case stunden_stellen:
            return minuten_stellen;
        case minuten_stellen:
            return wach_eingang;
        case pre_sleepmode:
            return wach_eingang;
        case debug_mode:
            return debug_mode;
        case pre_stoppuhr:
            return pre_stoppuhr;
        case zeitstellen_debug:
            return zeitstellen_debug;
        default: 
            return wach_eingang;
    }
}

status button3_nextState(status state){ // PD2, 
    switch(state){
        case schlafmodus:             
            return schlafmodus;
        case wach_eingang:
            return pre_sleepmode;
        case eins_anzeige:
            return wach_eingang; 
        case zwei_anzeige:
            return eins_anzeige;
        case drei_anzeige:
            return zwei_anzeige;
        case sekundenanzeiger_knightrider:
            return eins_anzeige;
        case stoppuhr:
            return sekundenanzeiger_knightrider;
        case zeit_stopp:
            return sekundenanzeiger_knightrider;
        case stunden_stellen:
            return stunden_stellen;
        case minuten_stellen:
            return minuten_stellen;
        case pre_sleepmode:
            allesAus();
            PWMWerteAus();
            return schlafmodus;
        case debug_mode:
            return drei_anzeige;
        case pre_stoppuhr:
            return sekundenanzeiger_knightrider;
        case zeitstellen_debug:
            return debug_mode;
        default: 
            return wach_eingang;
    }
}


void allesAus(){
    DDRB&=0x00;
    DDRC&=0x00;
}

void allesAn(){
    DDRC|=(1<<PC5)|(1<<PC4)|(1<<PC3)|(1<<PC2)|(1<<PC1)|(1<<PC0);
    DDRB|=(1<<PB5)|(1<<PB4)|(1<<PB3)|(1<<PB2)|(1<<PB1);
}


/*




*/