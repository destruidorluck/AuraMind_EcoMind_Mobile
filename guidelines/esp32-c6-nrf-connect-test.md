# ESP32-C6 nRF Connect Test Runbook

Use this runbook to validate the ESP32-C6 firmware directly from nRF Connect
before changing or testing the Flutter app integration.

For everyday testing, prefer the Flutter app bench:

1. Open Aura Mind.
2. Go to Configuracoes > Bluetooth.
3. In `Bancada ESP32-C6`, tap `Procurar ESP32`.
4. Tap the discovered `AuraMind-EcoMind` device in the Bluetooth list.
5. Use the ready-made buttons for ping, status, LED, Wi-Fi scan, Wi-Fi connect,
   backend health, and speak.

## Test Target

- BLE device name: `AuraMind-EcoMind`
- Previous/alternate firmware name: `AuraMind C6`
- BLE service: Nordic UART Service
- Service UUID: `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`
- RX characteristic, write commands here:
  `6E400002-B5A3-F393-E0A9-E50E24DCCA9E`
- TX characteristic, enable notifications here:
  `6E400003-B5A3-F393-E0A9-E50E24DCCA9E`

## Setup

1. Power on the ESP32-C6.
2. Open nRF Connect on the phone.
3. Start a BLE scan.
4. Connect to `AuraMind-EcoMind`.
5. Open the Nordic UART service.
6. Enable notifications on TX.
7. Write commands to RX using UTF-8/Text format.

## Command Sequence

Run these commands in order. Wait for the TX response after each command before
sending the next one.

| Step | Command | Expected result |
| --- | --- | --- |
| 1 | `{"cmd":"ping"}` | ESP32 responds with a JSON acknowledgement. |
| 2 | `{"cmd":"status"}` | ESP32 returns memory, CPU frequency, and Wi-Fi state. |
| 3 | `{"cmd":"led","color":"azul"}` | LED changes to blue. |
| 4 | `{"cmd":"led","color":"verde"}` | LED changes to green. |
| 5 | `{"cmd":"led","color":"vermelho"}` | LED changes to red. |
| 6 | `{"cmd":"led","color":"apagar"}` | LED turns off. |
| 7 | `{"cmd":"wifi_scan"}` | ESP32 returns nearby Wi-Fi networks. |
| 8 | `{"cmd":"wifi_connect","ssid":"SUA_REDE","password":"SUA_SENHA"}` | ESP32 connects and returns an IP address. Run only if Wi-Fi is not connected. |
| 9 | `{"cmd":"backend_health"}` | ESP32 returns backend health status. |
| 10 | `{"cmd":"speak","text":"Ola Lucas, eu sou o AuraMind."}` | ESP32 returns a text/event response. nRF Connect will not play audio. |

Do not commit real Wi-Fi passwords to the repository. Replace
`SUA_REDE` and `SUA_SENHA` only inside nRF Connect while testing.

## Success Criteria

- `AuraMind-EcoMind` appears in the BLE scan.
- BLE connection opens without errors.
- TX notifications receive JSON responses for `ping` and `status`.
- LED commands visibly change the LED state.
- `wifi_scan` returns one or more nearby networks.
- `wifi_connect` returns `connected: true` or an IP address when used.
- `backend_health` confirms the ESP32 can reach the configured backend.
- `speak` produces a response event/text. Audio playback belongs to the Flutter
  app/TTS flow, not nRF Connect.

## Result Log

| Check | Pass/Fail | Notes |
| --- | --- | --- |
| Device appears as `AuraMind-EcoMind` |  |  |
| Connected over BLE |  |  |
| Nordic UART service is present |  |  |
| TX notifications enabled |  |  |
| `ping` response received |  |  |
| `status` response received |  |  |
| LED color commands worked |  |  |
| `wifi_scan` returned networks |  |  |
| `wifi_connect` returned IP, if needed |  |  |
| `backend_health` succeeded |  |  |
| `speak` returned text/event |  |  |

## Quick Diagnostics

If `AuraMind-EcoMind` does not appear:

- Reset the ESP32-C6.
- Confirm no other phone/app is already connected.
- Confirm the firmware advertises the name `AuraMind-EcoMind`.

If BLE connects but Nordic UART is missing:

- The firmware is not exposing the expected Nordic UART service.
- Confirm the service UUID is `6E400001-B5A3-F393-E0A9-E50E24DCCA9E`.

If commands write successfully but no response appears:

- Enable notifications on TX.
- Confirm commands are written to RX, not TX.
- Confirm nRF Connect is writing as UTF-8/Text.

If `wifi_scan` fails:

- Move the ESP32 closer to the router.
- Confirm the firmware has Wi-Fi scan support enabled.

If `wifi_connect` fails:

- Check SSID and password.
- Prefer a 2.4 GHz network for ESP32 compatibility.
- Check whether the network blocks new devices or uses captive portal login.

If `backend_health` fails:

- Confirm Wi-Fi is connected first.
- Confirm the backend/ngrok URL configured in the firmware is still active.
- Test the backend health URL from a browser on the same phone.

## Flutter App Note

The Flutter app now has a BLE bench inside the Bluetooth settings screen. It
uses the same Nordic UART RX/TX UUIDs and sends the JSON commands above through
buttons, so nRF Connect is only needed as a fallback/debug tool.
