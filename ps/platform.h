#ifndef __PLATFORM_H_
#define __PLATFORM_H_

void init_platform();
void cleanup_platform();
#ifdef __MICROBLAZE__
void timer_callback();
#endif
#ifdef __PPC__
void timer_callback();
#endif
void platform_setup_timer();
void platform_enable_interrupts();
#endif

