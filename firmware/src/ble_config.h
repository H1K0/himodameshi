#pragma once

// BLE GATT UUIDs — источник истины: docs/spec/ble-protocol.md §1.1
// Изменения только через ADR + смену pv в протоколе.

constexpr char BLE_SERVICE_UUID[] = "484D0001-4A5B-6C7D-8E9F-A0B1C2D3E4F5";
constexpr char BLE_CHAR_CMD_UUID[] = "484D0002-4A5B-6C7D-8E9F-A0B1C2D3E4F5";
constexpr char BLE_CHAR_DATA_UUID[] = "484D0003-4A5B-6C7D-8E9F-A0B1C2D3E4F5";
