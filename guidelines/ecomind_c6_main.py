# pyright: reportMissingImports=false, reportAttributeAccessIssue=false
# pylint: disable=import-error,no-member
# Eco Mind ESP32-C6 firmware for Thonny / MicroPython
# BLE name: Eco Mind
# Protocol: Nordic UART Service (NUS), short commands + framed JSON.

import bluetooth
import json
import machine
import neopixel
import network
import time
import ubinascii

try:
    import urequests as requests
except ImportError:
    requests = None


def sleep_ms(ms):
    try:
        time.sleep_ms(ms)
    except AttributeError:
        time.sleep(ms / 1000)


def ticks_ms():
    try:
        return time.ticks_ms()
    except AttributeError:
        return int(time.time() * 1000)


def ticks_diff(new, old):
    try:
        return time.ticks_diff(new, old)
    except AttributeError:
        return new - old


DEVICE_NAME = "Eco Mind"
BACKEND_HEALTH_URL = "https://unlimited-sharpness-fondue.ngrok-free.dev/api/health"

LED_PIN = 8
LED_COUNT = 1
DEFAULT_BRIGHTNESS = 0.35

UART_SERVICE_UUID = bluetooth.UUID("6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
UART_RX_UUID = bluetooth.UUID("6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
UART_TX_UUID = bluetooth.UUID("6E400003-B5A3-F393-E0A9-E50E24DCCA9E")

_IRQ_CENTRAL_CONNECT = 1
_IRQ_CENTRAL_DISCONNECT = 2
_IRQ_GATTS_WRITE = 3

_FLAG_READ = 0x0002
_FLAG_WRITE_NO_RESPONSE = 0x0004
_FLAG_WRITE = 0x0008
_FLAG_NOTIFY = 0x0010

UART_TX = (UART_TX_UUID, _FLAG_READ | _FLAG_NOTIFY)
UART_RX = (UART_RX_UUID, _FLAG_WRITE | _FLAG_WRITE_NO_RESPONSE)
UART_SERVICE = (UART_SERVICE_UUID, (UART_TX, UART_RX))

COLORS = {
    "off": (0, 0, 0),
    "idle": (0, 80, 255),
    "blue": (0, 80, 255),
    "listening": (255, 150, 0),
    "amber": (255, 150, 0),
    "concentration": (255, 125, 0),
    "focus": (255, 125, 0),
    "processing": (130, 40, 255),
    "purple": (130, 40, 255),
    "responding": (150, 55, 255),
    "transcribing": (0, 220, 220),
    "cyan": (0, 220, 220),
    "success": (0, 255, 0),
    "green": (0, 255, 0),
    "error": (255, 0, 0),
    "red": (255, 0, 0),
    "wifi": (0, 255, 180),
    "backend": (80, 180, 255),
    "speaking": (0, 150, 255),
    "white": (255, 255, 255),
    "yellow": (255, 220, 0),
}

COLOR_ALIASES = {
    "apagar": "off",
    "desligar": "off",
    "azul": "blue",
    "verde": "green",
    "vermelho": "red",
    "roxo": "purple",
    "violeta": "purple",
    "ambar": "amber",
    "laranja": "amber",
    "ciano": "cyan",
    "amarelo": "yellow",
    "branco": "white",
    "ouvindo": "listening",
    "processando": "processing",
    "transcrevendo": "transcribing",
    "sucesso": "success",
    "erro": "error",
    "concentracao": "concentration",
    "concentração": "concentration",
    "foco": "focus",
    "respondendo": "responding",
    "falando": "speaking",
}

np = neopixel.NeoPixel(machine.Pin(LED_PIN), LED_COUNT)
brightness = DEFAULT_BRIGHTNESS
current_state = "idle"
wlan = network.WLAN(network.STA_IF)
frame_expected = 0
frame_parts = {}


def _scale(color):
    return tuple(max(0, min(255, int(value * brightness))) for value in color)


def set_led(color):
    rgb = _scale(color)
    for index in range(LED_COUNT):
        np[index] = rgb
    np.write()


def blink(color, count=2, delay_ms=120):
    for _ in range(count):
        set_led(color)
        sleep_ms(delay_ms)
        set_led(COLORS["off"])
        sleep_ms(delay_ms)
    set_led(COLORS.get(current_state, COLORS["idle"]))


def pulse(color, steps=8, delay_ms=35):
    global brightness
    old = brightness
    for step in range(steps):
        brightness = 0.10 + (step / max(1, steps - 1)) * 0.55
        set_led(color)
        sleep_ms(delay_ms)
    for step in range(steps, 0, -1):
        brightness = 0.10 + (step / max(1, steps)) * 0.55
        set_led(color)
        sleep_ms(delay_ms)
    brightness = old
    set_led(color)


def speaking_gradient():
    frames = [
        (0, 220, 220),
        (0, 180, 255),
        (40, 120, 255),
        (0, 180, 255),
    ]
    for color in frames:
        set_led(color)
        sleep_ms(90)


def normalize_state(value):
    text = str(value or "").strip().lower().replace("-", "_")
    text = COLOR_ALIASES.get(text, text)
    if text in ("ai_response", "response"):
        return "speaking"
    if text in COLORS:
        return text
    return "idle"


def show_state(state):
    global current_state
    current_state = normalize_state(state)
    if current_state == "processing":
        pulse(COLORS["processing"], steps=5, delay_ms=25)
    elif current_state == "success":
        blink(COLORS["success"], count=2, delay_ms=80)
    elif current_state == "error":
        blink(COLORS["error"], count=3, delay_ms=90)
    elif current_state == "speaking":
        speaking_gradient()
    elif current_state == "responding":
        responding_gradient()
    else:
        set_led(COLORS.get(current_state, COLORS["idle"]))


def responding_gradient():
    frames = [
        (150, 55, 255),
        (0, 190, 255),
        (190, 70, 255),
        (0, 150, 255),
    ]
    for color in frames:
        set_led(color)
        sleep_ms(90)


def advertising_payload(name=None, services=None):
    payload = bytearray()

    def append(adv_type, value):
        payload.extend((len(value) + 1, adv_type))
        payload.extend(value)

    append(0x01, b"\x06")
    if name:
        append(0x09, name.encode())
    if services:
        for uuid in services:
            raw = bytes(uuid)
            append(0x07 if len(raw) == 16 else 0x03, raw)
    return payload


class EcoMindBle:
    def __init__(self):
        self.ble = bluetooth.BLE()
        self.ble.active(True)
        self.ble.irq(self._irq)
        ((self.tx_handle, self.rx_handle),) = self.ble.gatts_register_services(
            (UART_SERVICE,)
        )
        self.connections = set()
        self.payload = advertising_payload(name=DEVICE_NAME, services=[UART_SERVICE_UUID])
        self.advertise()

    def advertise(self):
        self.ble.gap_advertise(100_000, adv_data=self.payload)
        print("BLE advertising:", DEVICE_NAME)
        show_state("idle")

    def send_json(self, data):
        text = json.dumps(data)
        print("TX:", text)
        for conn_handle in self.connections:
            try:
                self.ble.gatts_notify(conn_handle, self.tx_handle, text)
            except Exception as exc:
                print("Notify error:", exc)

    def _irq(self, event, data):
        if event == _IRQ_CENTRAL_CONNECT:
            conn_handle, _, _ = data
            self.connections.add(conn_handle)
            print("Phone connected:", conn_handle)
            show_state("success")
            self.send_json(
                {
                    "type": "event",
                    "event": "ble_connected",
                    "device": DEVICE_NAME,
                }
            )
        elif event == _IRQ_CENTRAL_DISCONNECT:
            conn_handle, _, _ = data
            self.connections.discard(conn_handle)
            print("Phone disconnected:", conn_handle)
            self.advertise()
        elif event == _IRQ_GATTS_WRITE:
            conn_handle, value_handle = data
            if value_handle == self.rx_handle:
                raw = self.ble.gatts_read(self.rx_handle)
                text = raw.decode("utf-8", "ignore").strip()
                print("RX:", text)
                handle_rx(text, self)


def handle_short_command(text, ble):
    if text.startswith("S:"):
        state = text[2:].strip() or "idle"
        show_state(state)
        ble.send_json({"type": "state_result", "state": current_state, "success": True})
        return True

    if text.startswith("L:"):
        color_name = normalize_state(text[2:].strip() or "idle")
        show_state(color_name)
        ble.send_json({"type": "led_result", "color": color_name, "success": True})
        return True

    if text == "BH":
        ble.send_json(backend_health())
        return True

    if text.startswith("B:"):
        set_brightness(text[2:].strip() or "35")
        ble.send_json({"type": "brightness_result", "value": int(brightness * 100)})
        return True

    return False


def handle_frame(text, ble):
    global frame_expected, frame_parts
    try:
        header, part = text[1:].split(":", 1)
        index_text, total_text = header.split("/", 1)
        index = int(index_text)
        total = int(total_text)
    except Exception:
        show_state("error")
        ble.send_json({"type": "error", "message": "invalid frame"})
        return

    if index < 1 or total < 1 or index > total or total > 200:
        show_state("error")
        ble.send_json({"type": "error", "message": "invalid frame index"})
        return

    if index == 1 or frame_expected != total:
        frame_expected = total
        frame_parts = {}

    frame_parts[index] = part
    print("FRAME:", index, "/", total)

    if len(frame_parts) < frame_expected:
        return

    try:
        encoded = "".join(frame_parts[i] for i in range(1, frame_expected + 1))
    except KeyError:
        show_state("error")
        ble.send_json({"type": "error", "message": "missing frame"})
        frame_expected = 0
        frame_parts = {}
        return

    frame_expected = 0
    frame_parts = {}

    try:
        decoded = ubinascii.a2b_base64(encoded).decode("utf-8")
    except Exception as exc:
        print("Frame decode error:", exc)
        show_state("error")
        ble.send_json({"type": "error", "message": "frame decode error"})
        return

    print("FRAMED RX:", decoded)
    handle_rx(decoded, ble)


def wifi_scan():
    show_state("wifi")
    wlan.active(True)
    rows = wlan.scan()
    networks = []
    for row in rows[:15]:
        ssid = row[0].decode("utf-8", "ignore")
        rssi = row[3]
        if ssid:
            networks.append({"ssid": ssid, "rssi": rssi})
    networks.sort(key=lambda item: item["rssi"], reverse=True)
    return {"type": "wifi_scan_result", "networks": networks[:12]}


def wifi_connect(ssid, password):
    show_state("wifi")
    if not ssid:
        show_state("error")
        return {"type": "wifi_connect_result", "success": False, "message": "missing_ssid"}
    wlan.active(True)
    if wlan.isconnected():
        wlan.disconnect()
        time.sleep(1)
    wlan.connect(ssid, password)
    start = ticks_ms()
    while not wlan.isconnected() and ticks_diff(ticks_ms(), start) < 18000:
        sleep_ms(300)
    if wlan.isconnected():
        ip = wlan.ifconfig()[0]
        show_state("success")
        return {"type": "wifi_connect_result", "success": True, "ssid": ssid, "ip": ip}
    show_state("error")
    return {"type": "wifi_connect_result", "success": False, "ssid": ssid, "message": "timeout"}


def backend_health():
    show_state("backend")
    if requests is None:
        show_state("error")
        return {
            "type": "backend_health_result",
            "success": False,
            "message": "urequests_unavailable",
        }
    if not wlan.isconnected():
        show_state("error")
        return {
            "type": "backend_health_result",
            "success": False,
            "message": "wifi_not_connected",
        }
    try:
        response = requests.get(BACKEND_HEALTH_URL)
        status = response.status_code
        body = response.text[:160]
        response.close()
        ok = 200 <= status < 300
        show_state("success" if ok else "error")
        return {
            "type": "backend_health_result",
            "success": ok,
            "status": status,
            "body": body,
        }
    except Exception as exc:
        show_state("error")
        return {
            "type": "backend_health_result",
            "success": False,
            "message": str(exc),
        }


def status_payload():
    wifi = {"connected": wlan.isconnected()}
    if wlan.isconnected():
        wifi["ip"] = wlan.ifconfig()[0]
    return {
        "type": "status",
        "device": DEVICE_NAME,
        "state": current_state,
        "brightness": int(brightness * 100),
        "wifi": wifi,
        "freq_mhz": machine.freq() / 1_000_000,
    }


def handle_rx(text, ble):
    if not text:
        return

    if text.startswith("#"):
        handle_frame(text, ble)
        return

    if handle_short_command(text, ble):
        return

    try:
        command = json.loads(text)
    except Exception as exc:
        print("JSON error:", exc)
        show_state("error")
        ble.send_json({"type": "error", "message": "syntax error in JSON"})
        return

    cmd = str(command.get("cmd", "")).strip().lower()
    try:
        if cmd == "ping":
            show_state("success")
            ble.send_json({"type": "event", "event": "pong", "device": DEVICE_NAME})
        elif cmd == "status":
            ble.send_json(status_payload())
        elif cmd == "state":
            state = command.get("state", "idle")
            show_state(state)
            ble.send_json({"type": "state_result", "state": current_state, "success": True})
        elif cmd == "led":
            color_name = normalize_state(command.get("color", "idle"))
            show_state(color_name)
            ble.send_json({"type": "led_result", "color": color_name, "success": True})
        elif cmd == "brightness":
            set_brightness(command.get("value", 35))
            ble.send_json({"type": "brightness_result", "value": int(brightness * 100)})
        elif cmd == "wifi_scan":
            ble.send_json(wifi_scan())
        elif cmd == "wifi_connect":
            ble.send_json(wifi_connect(command.get("ssid", ""), command.get("password", "")))
        elif cmd == "backend_health":
            ble.send_json(backend_health())
        elif cmd == "speak":
            text_to_speak = str(command.get("text", "")).strip()
            show_state("speaking")
            ble.send_json(
                {
                    "type": "speak_request",
                    "success": bool(text_to_speak),
                    "text": text_to_speak,
                    "message": "text_received_no_audio_on_c6",
                }
            )
        elif cmd == "reboot":
            ble.send_json({"type": "event", "event": "rebooting"})
            sleep_ms(250)
            machine.reset()
        else:
            show_state("error")
            ble.send_json({"type": "error", "message": "unknown command", "cmd": cmd})
    except Exception as exc:
        print("Command error:", exc)
        show_state("error")
        ble.send_json({"type": "error", "message": str(exc), "cmd": cmd})


def set_brightness(value):
    global brightness
    try:
        number = float(value)
    except Exception:
        number = 35
    if number > 1:
        number = number / 100
    brightness = max(0.02, min(1.0, number))
    set_led(COLORS.get(current_state, COLORS["idle"]))


show_state("idle")
ble = EcoMindBle()

print("=" * 50)
print("Eco Mind C6 ready")
print("BLE name:", DEVICE_NAME)
print("NUS service:", UART_SERVICE_UUID)
print("Backend:", BACKEND_HEALTH_URL)
print("LED NeoPixel pin:", LED_PIN)
print("=" * 50)
