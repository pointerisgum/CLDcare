//
//  ble_packet.h
//  iDispenser
//
//  Created by YongHee Nam on 2017. 11. 7..
//  Copyright © 2017년 YongHee Nam. All rights reserved.
//

#define ble_nus_header_length    2
#define ble_nus_prefix            '*'

#pragma pack(1)

typedef struct
{
    uint8_t header;
    uint8_t cmd;
    uint8_t buffer[1];
} ble_nus_data_t;

typedef struct
{
    uint16_t year;
    uint8_t  month, day, hour, min, sec;
    uint8_t  weekdays;
    uint8_t  take_hour, take_min;
} ble_date_time_t;

typedef struct
{
    uint32_t stored_count;
} ble_res_count_t;

typedef struct
{
    uint16_t index;
} ble_req_data_t;

typedef struct
{
    uint8_t    valid;
    uint8_t ttime[6];
} ble_res_data_t;

typedef struct
{
    uint8_t serial[19];
} ble_serial_data_t;

typedef struct
{
    uint32_t version;
} ble_version_t;

typedef struct
{
    uint8_t cmd[2];
} ble_cmd_data_t;

enum
{
    ncmd_take_time,
    ncmd_reset,
    ncmd_count,
    ncmd_get_data,
    ncmd_serial_data,
    ncmd_version,
    ncmd_firmware_uart,
};

#pragma pack()
