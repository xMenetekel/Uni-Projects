#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

volatile uint8_t PRELL1 = 0;

//PB6 PB7 Uhrenquarz


void main(){
DDRC=0xFF;
DDRB=0x00;
DDRD=0x00;
PORTD |= (1<<PD2);
PORTC |= 0xAA;
// PORTB |=(1<<PB6); //?
EIMSK |=(1<<INT0);
EICRA |= (1<<ISC01);
		sei();

	while(1){		
		_delay_ms(20);
		if(PRELL1 != 0)PRELL1--;
		}
	}

ISR(INT0_vect){
	if(PRELL1 == 0){
	PRELL1 = 7; //das hochsetzen um mehr zu entprellen
	
	//if((PINB & (1<<PINB6)) == 0){
		PORTC=PORTC++;
	
	}
	
}



