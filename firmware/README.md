# Himodameshi — Firmware

ESP32-S3 · Arduino framework · PlatformIO · Wokwi

## Окружение

| Компонент       | Версия                       |
| --------------- | ---------------------------- |
| Плата           | ESP32-S3-DevKitC-1-N8        |
| Framework       | Arduino (espressif32 6.13.0) |
| PlatformIO Core | 6.1.19                       |
| Python          | 3.12 (`firmware/.venv/`)     |
| NimBLE-Arduino  | 2.5.0                        |
| ArduinoJson     | 7.4.3                        |

## Первый запуск после клонирования

```bash
cd firmware

# Создать venv и установить PlatformIO
python -m venv .venv
.venv\Scripts\activate      # Windows
pip install -r requirements.txt

# Скачать toolchain и библиотеки, собрать прошивку
pio run
```

Toolchain (~500 MB) скачивается один раз в `~/.platformio/`.

## Структура папки

```
firmware/
├── src/
│   └── main.cpp          # точка входа
├── diagram.json          # схема Wokwi (ESP32-S3 + LED)
├── wokwi.toml            # привязка симулятора к артефактам сборки
├── platformio.ini        # конфигурация сборки
├── requirements.txt      # зависимости Python (platformio)
└── .venv/                # локальный venv, не в git
```

## Сборка

```bash
pio run                   # сборка
pio run --target clean    # очистить артефакты
```

Артефакты появляются в `.pio/build/esp32s3/`:

- `firmware.bin` — прошивка для загрузки
- `firmware.elf` — с отладочными символами (нужен Wokwi)

## Тестирование в симуляторе (Wokwi)

### Требования

- VS Code с расширением **Wokwi** (`wokwi.wokwi-vscode`)
- При первом запуске Wokwi попросит бесплатную лицензию — войти через GitHub

### Порядок действий

1. Собрать прошивку: `pio run`
2. В VS Code открыть `firmware/diagram.json`
3. Нажать кнопку **▶ Simulate** в правом верхнем углу редактора  
   (или `F1` → `Wokwi: Start Simulator`)
4. В панели **Serial Monitor** внизу появятся логи: `[himo] firmware started`
5. Красный светодиод на схеме начнёт мигать с периодом 1 с

### Схема (diagram.json)

```
GPIO2 ──── LED (красный) ──── 220 Ω ──── GND
```

### Горячие клавиши Wokwi

| Действие                         | Клавиша                          |
| -------------------------------- | -------------------------------- |
| Запустить / остановить симулятор | `F1` → Wokwi: Start Simulator    |
| Пауза                            | кнопка Pause в панели симулятора |
| Перезапустить                    | кнопка Reset на схеме ESP32-S3   |

## Загрузка на реальное железо

```bash
pio run --target upload           # автопоиск порта
pio run --target upload --upload-port COM3   # явный порт
pio device monitor                # Serial Monitor 115200 бод
```

## Отладка

`CORE_DEBUG_LEVEL=3` включён по умолчанию в `platformio.ini` — все ESP-IDF логи уровня WARNING и выше выводятся в Serial.

Для подробных логов (verbose):

```cpp
// platformio.ini
build_flags = -DCORE_DEBUG_LEVEL=5
```
