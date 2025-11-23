#ifndef KERNEL_H
#define KERNEL_H

#include <stdint.h>
#include <stddef.h>

/* ==================== Display Functions ==================== */
void clear_screen(void);
void kputs(const char *str);
void display_string(const char *str);
void display_hex(int num, int digits);
void set_text_color(uint8_t foreground, uint8_t background);
void kprintf(const char *format, ...);

/* ==================== Keyboard Functions ==================== */
void keyboard_init(void);
void keyboard_interrupt_handler(void);
char keyboard_read(void);
void keyboard_buffer_add(char c);
int keyboard_buffer_empty(void);

/* ==================== Memory Functions ==================== */
void memory_init(void);
void *kmalloc(size_t size);
void kfree(void *ptr);
void memory_info(void);
size_t memory_get_used(void);
size_t memory_get_total(void);

/* ==================== Timer Functions ==================== */
void timer_init(uint32_t freq);
void timer_interrupt_handler(void);
void timer_sleep(uint32_t ms);
uint32_t timer_get_ticks(void);

/* ==================== Disk Functions ==================== */
void disk_init(void);
int disk_read_sector(uint32_t lba, uint8_t *buffer);
int disk_write_sector(uint32_t lba, uint8_t *buffer);

/* ==================== Shell Functions ==================== */
void shell_init(void);
void shell_prompt(void);
void shell_execute(const char *cmd);

/* ==================== CPU Functions ==================== */
void cpu_info(void);

/* ==================== Interrupt/Exception Functions ==================== */
void idt_init(void);
void pic_init(void);
void irq_handler(int irq);
void exception_handler(int exception);

/* ==================== Graphics Functions ==================== */
void graphics_init(void);
void graphics_exit(void);
void graphics_set_pixel(int x, int y, uint8_t color);
uint8_t graphics_get_pixel(int x, int y);
void graphics_draw_line_h(int x1, int x2, int y, uint8_t color);
void graphics_draw_line_v(int x, int y1, int y2, uint8_t color);
void graphics_draw_rect(int x, int y, int w, int h, uint8_t color);
void graphics_fill_rect(int x, int y, int w, int h, uint8_t color);
void graphics_draw_circle(int cx, int cy, int r, uint8_t color);
void graphics_fill_circle(int cx, int cy, int r, uint8_t color);
void graphics_clear(uint8_t color);
void graphics_demo(void);
void graphics_set_palette(int index, uint8_t r, uint8_t g, uint8_t b);
int graphics_is_active(void);
int graphics_get_width(void);
int graphics_get_height(void);

/* ==================== Utility Functions ==================== */
int strcmp(const char *a, const char *b);
void strcpy(char *dst, const char *src);
int strlen(const char *str);
void itoa(int num, char *buffer, int base);

/* ==================== Performance Functions ==================== */
void show_stats(void);

/* ==================== Device Functions ==================== */
void devices_init(void);
void devices_list(void);
unsigned int devices_get_count(void);
unsigned int devices_count_by_type(unsigned int type);

#endif /* KERNEL_H */
