# ambientlivev2

## Установка (NWN2)

Ниже — простые шаги, чтобы включить систему Ambient Life в ваш модуль. Если вы работаете впервые, следуйте по порядку.

### 0) Что вам понадобится

1. **Neverwinter Nights 2 Toolset** (NWN2 Toolset).
2. Доступ к вашему модулю (открыт в Toolset).
3. Скрипты Ambient Life из папки `scripts/`.

### 1) Импорт скриптов в модуль

1. Откройте ваш модуль в NWN2 Toolset.
2. Импортируйте все файлы из папки `scripts/`:
   - Обычно это делается через **File → Import** (или аналогичное меню).
3. Убедитесь, что скрипты появились в списке скриптов модуля.

**Важно:** импортируйте **все** `.nss` файлы, потому что они ссылаются друг на друга через `#include`.

### 2) Скомпилируйте скрипты

1. В Toolset выполните **Compile** для всех скриптов (обычно Build → Compile Module).
2. Убедитесь, что в логе компиляции нет ошибок.

> Если Toolset ругается на файлы `*_inc.nss` (ошибка про отсутствие `main`),
> пометьте их как **Include** (Script Type) или исключите из компиляции.
> Компилируются только «входные» скрипты, которые привязываются к событиям
> (см. п. 3).
>
> **Важно про имена:** NWN2 ограничивает resref скриптов 16 символами.
> Поэтому в этом репозитории уже используются короткие имена входных скриптов
> (например, `al_mod_onleave`, `al_npc_onud`). Если вы переименовываете файлы,
> следите, чтобы resref оставался ≤ 16 символов — иначе компилятор выдаст
> `Failed to open RESREF`.

### 3) Подключите скрипты к событиям

#### 3.1 События области (Area)

Откройте нужную область и установите:

* **OnEnter** → `al_area_onenter`
* **OnExit** → `al_area_onexit`
* **OnHeartbeat** → оставить пустым

#### 3.2 События модуля (Module)

В свойствах модуля:

* **OnClientLeave** → `al_mod_onleave`

#### 3.3 События NPC

Для каждого NPC, которого должна контролировать система:

* **OnSpawn** → `al_npc_onspawn`
* **OnDeath** → `al_npc_ondeath`
* **OnUserDefined** → `al_npc_onud`

### 4) Назначение ролей или активностей NPC

Есть два способа настроить поведение NPC:

#### Вариант A — через роль

1. В свойствах NPC добавьте локальный int:
   * `al_role` = ID роли.
2. Возможные роли (ID):
   * `1` — Bartender
   * `2` — Barmaid
   * `3` — Light Keeper
   * `4` — Smith
   * `5` — Cook
   * `6` — Musician
   * `7` — Trainer
   * `8` — Thief
   * `9` — Merchant
   * `10` — Guard
   * `11` — Citizen

Система сама заполнит слоты `a0..a5` активностью по умолчанию.

#### Вариант B — вручную через слоты

1. В свойствах NPC задайте локальные int:
   * `a0`, `a1`, `a2`, `a3`, `a4`, `a5`
2. Каждый слот — ID активности (см. `al_acts_inc.nss`).

### 5) Настройка маршрутов (waypoints)

#### 5.1 Общие маршруты по слотам

Если хотите, чтобы NPC ходил по маршруту в конкретный слот суток — создайте waypoints с тегами.
Маршрут по слоту используется **для любой активности** в этом слоте и имеет приоритет над
специальными маршрутами:

* `AL_WP_S0`, `AL_WP_S1`, `AL_WP_S2`, `AL_WP_S3`, `AL_WP_S4`, `AL_WP_S5`

#### 5.2 Маршруты для специальных активностей

* Тренировка (Pace): `AL_WP_PACE`
* WWP: `AL_WP_WWP`

### 6) Специальные пары NPC

#### 6.1 Тренировочные партнёры

1. Назначьте двум NPC теги:
   * `FACTION_NPC1`
   * `FACTION_NPC2`
2. На уровне **области** добавьте локальные object-переменные:
   * `al_training_npc1_ref` → ссылка на `FACTION_NPC1`
   * `al_training_npc2_ref` → ссылка на `FACTION_NPC2`

#### 6.2 Bartender + Barmaid

На уровне **области** задайте локальные object-переменные:

* `al_bar_bartender_ref` → ссылка на NPC с ролью Bartender
* `al_bar_barmaid_ref` → ссылка на NPC с ролью Barmaid

### 7) Межзонные переходы по маршруту (опционально)

Если маршрут должен переносить NPC в другую область (jump):

1. На нужном waypoint’е задайте **локальную локацию**:
   * `al_transition_location` (готовая location)

**Или** альтернативный вариант:

1. На waypoint’е задайте локальные переменные:
   * `al_transition_area` (object области)
   * `al_transition_x`, `al_transition_y`, `al_transition_z` (float)
   * `al_transition_facing` (float)

### 8) Ограничения, о которых важно помнить

* В реестре на область максимум **100 NPC**. Если NPC больше — лишние не управляются.
* Система не использует heartbeats на NPC — это нормально.
* Для работы маршрутов используйте **waypoints**, а не поиск объектов по тегам в рантайме.

### 9) Быстрая проверка (Smoke Test)

1. Запустите модуль.
2. Войдите персонажем в область:
   * NPC должны появиться (если были скрыты) и начать анимации.
3. Покиньте область:
   * NPC должны скрыться (pause).
4. Подождите смены времени суток:
   * NPC должны менять активность по слотам.

Если что-то не работает, проверьте:

* назначения событий (п. 3);
* наличие ролей/слотов (п. 4);
* наличие waypoints (п. 5);
* компиляцию скриптов (п. 2).

## Toolset bindings

* Area OnEnter: `al_area_onenter`
* Area OnExit: `al_area_onexit`
* Module OnClientLeave: `al_mod_onleave`
* NPC OnSpawn (registration): `al_npc_onspawn`
* NPC OnDeath (unregister): `al_npc_ondeath`
* NPC OnUserDefined: `al_npc_onud`

## Role activity defaults

You can assign a role to an NPC by setting the local int `al_role` in the toolset.
On spawn the system will map that role to a default activity and fill slots `a0..a5` with
the matching activity ID. This happens once per NPC and marks `al_role_applied` so custom
slot values can still be set manually afterwards.

Available roles are declared in `AL_Role_Activities_Inc`:

* `AL_ROLE_BARTENDER`, `AL_ROLE_BARMAID`, `AL_ROLE_LIGHT_KEEPER`
* `AL_ROLE_SMITH`, `AL_ROLE_COOK`, `AL_ROLE_MUSICIAN`
* `AL_ROLE_TRAINER`, `AL_ROLE_THIEF`, `AL_ROLE_MERCHANT`
* `AL_ROLE_GUARD`, `AL_ROLE_CITIZEN`

## Dynamic slot updates

If you change an NPC activity slot (`a0..a5`) at runtime, call
`AL_RefreshRouteForSlot(oNpc, nSlot)` afterwards to cache the waypoint route
for that slot. Slot routes (`AL_WP_S0..AL_WP_S5`) apply to any activity and take
priority over activity-specific routes. This keeps route changes in sync
without needing to respawn the NPC.

### Example

Attach the scripts in the toolset event slots:

* Area events:
  * OnEnter → `al_area_onenter`
  * OnExit → `al_area_onexit`
  * OnHeartbeat → leave empty (system uses AreaTick via DelayCommand)
* Module events:
  * OnClientLeave → `al_mod_onleave`
* NPC events:
  * OnSpawn → `al_npc_onspawn`
  * OnDeath → `al_npc_ondeath`
  * OnUserDefined → `al_npc_onud`
