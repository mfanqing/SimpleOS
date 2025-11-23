#include "kernel.h"

// Device detection and enumeration
#define MAX_DEVICES 16

typedef struct {
    unsigned int type;      // 0=disk, 1=cdrom, 2=network
    unsigned char id;       // Device ID
    unsigned char status;   // 0=offline, 1=online
    const char *name;
} device_t;

static device_t devices[MAX_DEVICES];
static unsigned int device_count = 0;

void devices_init(void) {
    device_count = 0;
    
    // Add primary master drive
    devices[device_count].type = 0;
    devices[device_count].id = 0x80;
    devices[device_count].status = 1;
    devices[device_count].name = "HDD0";
    device_count++;
    
    // Add floppy drive
    devices[device_count].type = 0;
    devices[device_count].id = 0x00;
    devices[device_count].status = 1;
    devices[device_count].name = "FDD0";
    device_count++;
    
    // Add secondary master drive
    devices[device_count].type = 0;
    devices[device_count].id = 0x81;
    devices[device_count].status = 0;
    devices[device_count].name = "HDD1";
    device_count++;
}

unsigned int devices_get_count(void) {
    return device_count;
}

device_t *devices_get(unsigned int index) {
    if (index < device_count) {
        return &devices[index];
    }
    return NULL;
}

void devices_list(void) {
    display_string("Detected Devices:\n");
    display_string("─────────────────\n");
    
    for (unsigned int i = 0; i < device_count; i++) {
        device_t *dev = &devices[i];
        
        display_string("[");
        display_hex(i, 1);
        display_string("] ");
        display_string((char *)dev->name);
        display_string(" - ");
        
        switch (dev->type) {
            case 0: display_string("Storage"); break;
            case 1: display_string("CDROM"); break;
            case 2: display_string("Network"); break;
            default: display_string("Unknown"); break;
        }
        
        display_string(" (");
        display_string(dev->status ? "Online" : "Offline");
        display_string(")\n");
    }
    
    display_string("\n");
}

// Get total device count
unsigned int devices_count_by_type(unsigned int type) {
    unsigned int count = 0;
    for (unsigned int i = 0; i < device_count; i++) {
        if (devices[i].type == type) {
            count++;
        }
    }
    return count;
}
