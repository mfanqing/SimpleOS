/* SimpleOS Graphics Module - VGA 320x200 Graphics Mode */

#include "kernel.h"

/* VGA Graphics Mode Constants */
#define VGA_GRAPHICS_MODE 0x13          /* 320x200, 256 colors */
#define VGA_TEXT_MODE 0x03              /* 80x25 text mode */
#define GRAPHICS_WIDTH 320
#define GRAPHICS_HEIGHT 200
#define VGA_MEMORY_GRAPHICS 0xA0000     /* Graphics video memory */

/* VGA I/O Ports */
#define VGA_CRTC_INDEX 0x3D4
#define VGA_CRTC_DATA 0x3D5
#define VGA_MISC_OUTPUT 0x3C2
#define VGA_SEQ_INDEX 0x3C4
#define VGA_SEQ_DATA 0x3C5

static uint8_t *graphics_buffer = (uint8_t *)VGA_MEMORY_GRAPHICS;
static int graphics_mode = 0;  /* 0 = text, 1 = graphics */

/* Simple port I/O helper */
static inline void outb(uint16_t port, uint8_t val) {
    asm volatile("outb %0, %1" : : "a"(val), "Nd"(port));
}

/* Switch to VGA Graphics Mode (320x200, 256 colors) */
void graphics_init(void) {
    /* Set VGA mode 0x13 (320x200 256-color graphics) */
    asm volatile("int $0x10" : : "a" (0x13) : "memory");
    graphics_mode = 1;
}

/* Switch back to text mode */
void graphics_exit(void) {
    /* Set text mode 0x03 (80x25) */
    asm volatile("int $0x10" : : "a" (0x03) : "memory");
    graphics_mode = 0;
}

/* Set a pixel at (x, y) with given color (0-255) */
void graphics_set_pixel(int x, int y, uint8_t color) {
    if (x >= 0 && x < GRAPHICS_WIDTH && y >= 0 && y < GRAPHICS_HEIGHT) {
        graphics_buffer[y * GRAPHICS_WIDTH + x] = color;
    }
}

/* Get pixel color at (x, y) */
uint8_t graphics_get_pixel(int x, int y) {
    if (x >= 0 && x < GRAPHICS_WIDTH && y >= 0 && y < GRAPHICS_HEIGHT) {
        return graphics_buffer[y * GRAPHICS_WIDTH + x];
    }
    return 0;
}

/* Draw a horizontal line from (x1, y) to (x2, y) */
void graphics_draw_line_h(int x1, int x2, int y, uint8_t color) {
    if (y < 0 || y >= GRAPHICS_HEIGHT) return;
    if (x1 > x2) { int tmp = x1; x1 = x2; x2 = tmp; }
    for (int x = x1; x <= x2; x++) {
        graphics_set_pixel(x, y, color);
    }
}

/* Draw a vertical line from (x, y1) to (x, y2) */
void graphics_draw_line_v(int x, int y1, int y2, uint8_t color) {
    if (x < 0 || x >= GRAPHICS_WIDTH) return;
    if (y1 > y2) { int tmp = y1; y1 = y2; y2 = tmp; }
    for (int y = y1; y <= y2; y++) {
        graphics_set_pixel(x, y, color);
    }
}

/* Draw a rectangle outline */
void graphics_draw_rect(int x, int y, int w, int h, uint8_t color) {
    graphics_draw_line_h(x, x + w - 1, y, color);
    graphics_draw_line_h(x, x + w - 1, y + h - 1, color);
    graphics_draw_line_v(x, y, y + h - 1, color);
    graphics_draw_line_v(x + w - 1, y, y + h - 1, color);
}

/* Fill a rectangle with color */
void graphics_fill_rect(int x, int y, int w, int h, uint8_t color) {
    for (int dy = 0; dy < h; dy++) {
        for (int dx = 0; dx < w; dx++) {
            graphics_set_pixel(x + dx, y + dy, color);
        }
    }
}

/* Draw a filled circle (Midpoint Circle Algorithm) */
void graphics_draw_circle(int cx, int cy, int r, uint8_t color) {
    int x = 0;
    int y = r;
    int d = 3 - 2 * r;
    
    while (x <= y) {
        graphics_set_pixel(cx + x, cy + y, color);
        graphics_set_pixel(cx - x, cy + y, color);
        graphics_set_pixel(cx + x, cy - y, color);
        graphics_set_pixel(cx - x, cy - y, color);
        graphics_set_pixel(cx + y, cy + x, color);
        graphics_set_pixel(cx - y, cy + x, color);
        graphics_set_pixel(cx + y, cy - x, color);
        graphics_set_pixel(cx - y, cy - x, color);
        
        if (d < 0) {
            d = d + 4 * x + 6;
        } else {
            d = d + 4 * (x - y) + 10;
            y--;
        }
        x++;
    }
}

/* Fill a circle */
void graphics_fill_circle(int cx, int cy, int r, uint8_t color) {
    for (int x = -r; x <= r; x++) {
        for (int y = -r; y <= r; y++) {
            if (x * x + y * y <= r * r) {
                graphics_set_pixel(cx + x, cy + y, color);
            }
        }
    }
}

/* Clear the entire graphics screen with a color */
void graphics_clear(uint8_t color) {
    uint32_t pixels = GRAPHICS_WIDTH * GRAPHICS_HEIGHT;
    for (uint32_t i = 0; i < pixels; i++) {
        graphics_buffer[i] = color;
    }
}

/* Draw a simple GUI demo with boxes and shapes */
void graphics_demo(void) {
    graphics_clear(0);  /* Black background */
    
    /* Title bar - dark blue */
    graphics_fill_rect(0, 0, GRAPHICS_WIDTH, 20, 1);
    
    /* Window 1 - red */
    graphics_fill_rect(20, 40, 120, 80, 12);
    graphics_draw_rect(20, 40, 120, 80, 4);  /* Yellow border */
    
    /* Window 2 - green */
    graphics_fill_rect(180, 40, 120, 80, 2);
    graphics_draw_rect(180, 40, 120, 80, 4);  /* Yellow border */
    
    /* Window 3 - cyan */
    graphics_fill_rect(100, 130, 120, 60, 3);
    graphics_draw_rect(100, 130, 120, 60, 4);  /* Yellow border */
    
    /* Draw some circles */
    graphics_fill_circle(50, 150, 15, 14);   /* Light red circle */
    graphics_fill_circle(150, 160, 12, 11);  /* Cyan circle */
    graphics_fill_circle(250, 140, 18, 10);  /* Green circle */
}

/* Set VGA palette entry (DAC register) */
void graphics_set_palette(int index, uint8_t r, uint8_t g, uint8_t b) {
    /* Write index to DAC write address register */
    outb(0x3C8, index);
    /* Write RGB values (6-bit each) */
    outb(0x3C9, r >> 2);
    outb(0x3C9, g >> 2);
    outb(0x3C9, b >> 2);
}

/* Is graphics mode active? */
int graphics_is_active(void) {
    return graphics_mode;
}

/* Get graphics dimensions */
int graphics_get_width(void) {
    return GRAPHICS_WIDTH;
}

int graphics_get_height(void) {
    return GRAPHICS_HEIGHT;
}
