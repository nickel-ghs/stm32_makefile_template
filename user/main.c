#include "sys.h"
#include "delay.h"
#include "usart.h"
#include "led.h"

int main(void)
{
    delay_init();
    LED_Init();
    while (1)
    {
        LED0 = 0;
        LED1 = 1;
        delay_ms(300);
        LED0 = 1;
        LED1 = 0;
        delay_ms(1000);
    }
    return 0;
}
