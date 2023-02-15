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


//epochtime_cover 캡 열린 시간
//epochtime_body 몸통이 분리 된 시간

typedef struct {
    uint16_t company_identifier;//0,1
    uint8_t device_last_name;   //2
    uint8_t pairing;            //3
    uint32_t epochtime_body;   //4,5,6,7
    uint16_t count;             //8,9
    uint16_t info_count;        //10,11
    uint8_t  bat;               //12
    uint32_t epochtime1;        //최근 복약시간
    uint32_t epochtime2;        //최근 -1 복약시간
    uint32_t epochtime3;        //최근 -2 복약시간
    uint16_t cover_count;
    uint16_t body_count;
} dispenser_manuf_data_t;

////기울기 데이터
//typedef struct {
//    uint16_t company_identifier;    //19791
//    uint8_t mac_identifier;         //95 -> 95
//    uint16_t info_ir1;               //204 -> 139
//    uint8_t info_identifier[3];     //07:08:08 -> 08:07:08 -> 08:08:07
//    uint16_t count;                 //34 -> 35
//    uint16_t info_count;            //41 -> 44
//    uint8_t bat;
//    uint32_t epochtime1;
//    uint32_t epochtime2;
//    uint32_t epochtime3;
//    uint32_t epochtime4;
//    int16_t info_ir2;               //199 -> 201
//    int16_t info_ir3;               //202 -> 199
//} dispenser_tilt_data_t;



//기울기 펌웨어 업데이트 버전
//기울기 데이터
typedef struct {
    uint16_t company_identifier;    //19791
    uint8_t mac_identifier;         //0     //95 -> 95
    uint8_t reservedbyte;               //1
    uint8_t body_identifier;              //2               //식별자(body infomation on/off)
    uint8_t info_identifier[3];     //07:08:08 -> 08:07:08 -> 08:08:07
    uint16_t count;                 //34 -> 35
    uint16_t info_count;            //41 -> 44
    uint8_t bat;
    uint32_t epochtime1;
    uint32_t epochtime2;
    uint32_t epochtime3;
    uint32_t epochtime_cover;              //datetime_cover 뚜껑 열림
//    int16_t info_ir2;               //199 -> 201
//    int16_t info_ir3;               //202 -> 199
} dispenser_tilt_data_t_v2;


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



#pragma pack()

