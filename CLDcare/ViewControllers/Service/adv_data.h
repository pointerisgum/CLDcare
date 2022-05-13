#pragma once

#pragma pack(1)

#define BLE_MAC_LEN 6

//토출 데이터
//typedef struct {
//    uint16_t company_identifier;
//    uint8_t  mac[6];
//    uint32_t count;
//    uint8_t  bat;
//    //uint8_t  last_detect_time[6];
//    uint32_t epochtime1;
//    uint32_t epochtime2;
//    uint32_t epochtime3;
//} dispenser_manuf_data_t;

typedef struct {
    uint16_t company_identifier;
    uint8_t addr[2];
    uint32_t epochtime_cover;
    uint16_t count;
    uint16_t info_count;
    uint8_t  bat;
    uint32_t epochtime1;
    uint32_t epochtime2;
    uint32_t epochtime3;
    uint32_t reserved;
} dispenser_manuf_data_t;

//typedef struct {
//    uint16_t company_identifier;
//    uint8_t  addr[2];
//    uint32_t epochtime_cover;
//    uint16_t  count;
//    uint16_t  info_count;
//    uint8_t  bat;
//    uint32_t epochtime1; //날짜
//    uint32_t epochtime2;
//    uint32_t epochtime3;
//    uint32_t reserved;
//} dispenser_manuf_data_t2;


//기울기 데이터
typedef struct {
    uint16_t company_identifier;    //19791
    uint8_t mac_identifier;         //95 -> 95
    int16_t info_ir1;               //204 -> 139
    uint8_t info_identifier[3];     //07:08:08 -> 08:07:08 -> 08:08:07
    uint16_t count;                 //34 -> 35
    uint16_t info_count;            //41 -> 44
    uint8_t bat;
    uint32_t epochtime1;
    uint32_t epochtime2;
    uint32_t epochtime3;
    int16_t info_ir2;               //199 -> 201
    int16_t info_ir3;               //202 -> 199
} dispenser_tilt_data_t;

#pragma pack()

