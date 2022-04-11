#pragma once

#pragma pack(1)

#define BLE_MAC_LEN 6

typedef struct
{
    uint16_t company_identifier;
    uint8_t  mac[BLE_MAC_LEN];
    uint32_t count;                         //9
    uint8_t  bat;                           //13
    //uint8_t  last_detect_time[6];
    uint32_t epochtime1; //날짜
    uint32_t epochtime2;
    uint32_t epochtime3;
} dispenser_manuf_data_t;

#pragma pack()

