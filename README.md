# ambientlivev2

Полная документация системы Ambient Life (NWN2). Этот README является
каноническим источником информации по архитектуре, настройке и ограничениям.

## Оглавление

1. [Назначение и цели](#назначение-и-цели)
2. [Ключевые требования производительности](#ключевые-требования-производительности)
3. [Архитектура и компоненты](#архитектура-и-компоненты)
4. [Слоты времени и тики области](#слоты-времени-и-тики-области)
5. [Событийный протокол](#событийный-протокол)
6. [Локальные переменные (locals)](#локальные-переменные-locals)
7. [Реестр NPC (dense array)](#реестр-npc-dense-array)
8. [Потоки выполнения](#потоки-выполнения)
9. [Маршруты и переходы между областями](#маршруты-и-переходы-между-областями)
10. [Активности, роли и анимации](#активности-роли-и-анимации)
11. [Установка и подключение](#установка-и-подключение)
12. [Конфигурация NPC](#конфигурация-npc)
13. [Ограничения и риски](#ограничения-и-риски)
14. [Проверка работоспособности](#проверка-работоспособности)
15. [Репозиторий](#репозиторий)

---

## Назначение и цели

Ambient Life — высокопроизводительная система «жизнедеятельности» NPC, построенная
на событийной модели NWScript. Цели:

- **нулевая активность**, когда игроков в области нет;
- **минимальная активность** при наличии игроков (один таймер на область);
- управление поведением NPC **только через события**, без heartbeats и фоновых циклов;
- отсутствие runtime-поисков по тегам/строкам для жизнедеятельности.

Система использует стандартные события NWN2 (OnEnter/OnExit/OnUserDefined и т. п.)
и собственные user-defined события для синхронизации NPC.

## Ключевые требования производительности

Инварианты, на которых держится архитектура:

- Нет heartbeat на NPC.
- Нет периодических тиков на NPC.
- Один тик на область и только при наличии PC.
- При неизменном слоте суток система выполняет минимум работы (проверка слота +
  планирование следующего тика).
- Никаких runtime-поисков по тегам/строкам (GetObjectByTag, GetNearestObjectByTag)
  для управления поведением.
- Все управляемые NPC должны быть в плотном реестре.

## Архитектура и компоненты

### Area Controller (контроллер области)

Ответственность:

- отслеживать присутствие игроков в области;
- управлять жизненным циклом области (activate → tick → deactivate);
- вычислять слот суток (0–5);
- рассылать события NPC:
  - `EVT_RESYNC` при активации;
  - `EVT_SLOT_x` только при смене слота.

Техническая основа:

- OnEnter/OnExit области + единый таймер через `DelayCommand`.

### NPC Agent (агент NPC)

Ответственность:

- принимать `OnUserDefined` события;
- хранить «последний применённый слот»;
- применять активность и маршрут для слота;
- корректно скрываться/раскрываться при активации/деактивации области.

### NPC Registry (реестр NPC)

Ответственность:

- хранить NPC в плотном массиве `al_npc_0..al_npc_99`;
- обеспечивать быстрый O(1) `add/remove` через swap-remove;
- не допускать дыр и обходов всего мира.

## Слоты времени и тики области

### Слоты суток

Сутки делятся на 6 слотов по 4 часа. Формула:

```
slot = floor(GetTimeHour() / 4)  // 0..5
```

### Период тика

Тик области выполняется каждые **45 секунд реального времени** (настраивается
в `AL_TICK_PERIOD`). Таймер работает только если в области есть игроки.

## Событийный протокол

### Диапазон событий

- `AL_EVT_SLOT_BASE = 3000`
- `AL_EVT_SLOT_0..5 = 3000..3005`
- `AL_EVT_RESYNC = 3006`
- `AL_EVT_ROUTE_REPEAT = 3007` (повтор маршрута)

### Доставка событий

- Создание: `EventUserDefined(n)`
- Доставка: `SignalEvent(target, event)`
- Приём: `GetUserDefinedEventNumber()`

**Важно:** `SignalEvent` исполняется после завершения текущего скрипта.

## Локальные переменные (locals)

### На области

| Local | Тип | Назначение |
| --- | --- | --- |
| `al_player_count` | int | кол-во игроков в области |
| `al_tick_token` | int | токен тика (защита от старых DelayCommand) |
| `al_sync_tick` | int | счётчик для периодической синхронизации реестра |
| `al_slot` | int | текущий слот суток (0..5) |
| `al_npc_count` | int | размер реестра NPC |
| `al_npc_0..al_npc_99` | object | плотный реестр NPC |
| `al_slot_activity_<slot>` | int | fallback-активность для слота (если нет маршрута) |
| `al_default_activity` | int | fallback-активность по умолчанию (если нет маршрута) |
| `al_training_npc1_ref` / `al_training_npc2_ref` | object | ссылки на тренировочную пару (задаются в toolset) |
| `al_training_npc1` / `al_training_npc2` | object | закешированные ссылки на тренировочную пару |
| `al_training_partner_cached` | int | флаг кеша тренировочной пары |
| `al_bar_bartender_ref` / `al_bar_barmaid_ref` | object | ссылки на барную пару (задаются в toolset) |
| `al_bar_bartender` / `al_bar_barmaid` | object | закешированные ссылки на барную пару |

### На NPC

| Local | Тип | Назначение |
| --- | --- | --- |
| `al_last_slot` | int | последний применённый слот |
| `al_last_area` | object | последняя область NPC |
| `al_training_partner` | object | партнёр для тренировки |
| `al_bar_pair` | object | барная пара (barmaid/bartender) |
| `r<slot>_n` | int | количество точек маршрута слота |
| `r<slot>_<idx>` | location | точка маршрута слота |
| `r<slot>_tag` | string | тег маршрута слота |
| `r_slot` | int | активный слот маршрута |
| `r_idx` | int | индекс активной точки маршрута |
| `r_active` | int | маршрут активен |
| `al_slot_activity_<slot>` | int | fallback-активность для слота (если нет маршрута) |
| `al_default_activity` | int | fallback-активность по умолчанию (если нет маршрута) |

## Реестр NPC (dense array)

### Регистрация

- `AL_RegisterNPC(oNpc)` добавляет NPC в `al_npc_count` + `al_npc_<idx>`.
- При достижении лимита (`AL_MAX_NPCS = 100`) новые NPC не регистрируются.

### Удаление

- `AL_UnregisterNPC(oNpc)` удаляет NPC через swap-remove:
  - заменяет текущий элемент последним,
  - уменьшает `al_npc_count`.

### Синхронизация

`AL_SyncAreaNPCRegistry(oArea)` выполняет:

- удаление невалидных ссылок;
- перенос NPC, сменившего область, в новый реестр;
- обновление `al_last_area`.

Синхронизация выполняется:

- при активации области;
- периодически в тике области (каждые 4 тика).

## Потоки выполнения

### Активация области (PC 0 → 1)

OnEnter области:

1. Увеличение `al_player_count`.
2. Если теперь `al_player_count == 1`:
   - инкремент `al_tick_token`;
   - вычисление слота `al_slot`;
   - кеш тренировочных партнёров;
   - кеш маршрутов области;
   - синхронизация реестра;
   - раскрытие NPC + `EVT_RESYNC`.
   - запуск таймера тика (`DelayCommand(AL_TICK_PERIOD, AreaTick)`).

### Деактивация области (PC 1 → 0)

OnExit или OnClientLeave:

1. Уменьшение `al_player_count`.
2. Если теперь `al_player_count == 0`:
   - инкремент `al_tick_token` (убивает старые DelayCommand);
   - скрытие NPC (`SetScriptHidden`) и очистка действий (если включено).

### Тик области (AreaTick)

1. Если игроков нет — выход.
2. Проверка токена тика.
3. Периодическая синхронизация реестра.
4. Вычисление слота.
5. Если слот не изменился — планирование следующего тика.
6. Если слот изменился:
   - `al_slot = newSlot`;
   - рассылка `EVT_SLOT_x` всем NPC;
   - планирование следующего тика.

### Обработка NPC (OnUserDefined)

1. Определение слота по событию (`RESYNC`, `SLOT_x`, `ROUTE_REPEAT`).
2. Если слот не изменился — выход.
3. Обновление маршрута (при необходимости).
4. Получение активности с текущего waypoint’а.
5. Очистка маршрута, если он не нужен.
6. Постановка маршрута в очередь (если нужен).
7. Применение активности (анимации).

## Маршруты и переходы между областями

### Маршруты NPC (упрощённый режим)

 Маршрут хранится на NPC в `r<slot>_*`. При смене слота
 выполняется `AL_RefreshRouteForSlot`, которая обновляет маршрут, если:

- поменялся тег маршрута (по слоту), или
- маршрута ещё нет.

Маршрут определяется локальным string на NPC:

- `alwp0..alwp5` — тег маршрута для соответствующего слота.

Если локальный `alwp<slot>` не задан, используется дефолтный тег
`AL_WP_S<slot>` для обратной совместимости.

Маршрут строится **напрямую по waypoint’ам области** с соответствующим тегом
и не требует кеширования или `al_route_index`. Система берёт максимум
**10 точек на маршрут** в порядке обхода объектов области.

Для waypoint’ов можно задать **межзонный переход**:

- предпочтительный способ — локальная `location` на waypoint `al_transition_location`;
- альтернативный способ — `al_transition_area` + `al_transition_x/y/z/facing`.

При выполнении маршрута NPC может выполнить `ActionJumpToLocation` и
зарегистрироваться в новом реестре области.

Активность на маршруте берётся с текущего waypoint’а `al_activity` и является
единственным источником правды для анимаций на маршруте.
Если `al_activity` не задан, NPC считается скрытым (активность 0).
Если для слота нет маршрута, применяется fallback-логика
`AL_GetWaypointActivityForSlot`: сначала `al_slot_activity_<slot>`, затем
`al_default_activity` на NPC/области.
Если для слота есть маршрут, NPC будет двигаться по нему независимо от
выбранной активности, **кроме активности 0**. Активность 0 (Hidden)
останавливает маршрут и скрывает NPC. Исключение — активности, требующие
конкретный тег маршрута (например, `TrainerPace`/`WWP`): в этом случае маршрут
используется только при совпадении тега.

## Активности и анимации

Активность задаётся **только** локальным int `al_activity` на waypoint.
Слоты `a0..a5` и роли больше не используются.
Активность 0 (Hidden) останавливает маршрут и скрывает NPC.
Активности с требованием маршрута (`TrainerPace`/`WWP`) применяются только
при наличии маршрута с нужным тегом; остальные активности не блокируют
движение по любому маршруту в слоте.

### Активности (ID → анимации)

Система хранит статическое сопоставление ID → анимации в `al_acts_inc.nss`.

> Формат анимаций:
> - **Custom**: строки, проигрываются через `PlayCustomAnimation`.
> - **Numeric**: ID, проигрываются через `ActionPlayAnimation`.

| ID | Activity | Анимации | Требования |
| --- | --- | --- | --- |
| 0 | Hidden | — | скрыт |
| 1 | ActOne | Custom: lookleft, lookright | — |
| 2 | ActTwo | Custom: lookleft, lookright | — |
| 3 | Dinner | Custom: sitdrink, siteat, sitidle | — |
| 4 | MidnightBed | Custom: laydownB, proneB | — |
| 5 | SleepBed | Custom: laydownB, proneB | — |
| 6 | Wake | Custom: sitdrink, siteat, sitidle | — |
| 7 | Agree | Custom: chuckle, flirt, nodyes | — |
| 8 | Angry | Custom: intimidate, nodno, talkshout<br>Numeric: 10 | — |
| 9 | Sad | Custom: talksad, tired<br>Numeric: 9 | — |
| 10 | Cook | Custom: cooking02, disablefront<br>Numeric: 35, 36 | — |
| 11 | DanceFemale | Custom: curtsey, dance01<br>Numeric: 27 | — |
| 12 | DanceMale | Custom: bow, dance01, dance02 | — |
| 13 | Drum | Custom: bow, playdrum | — |
| 14 | Flute | Custom: curtsey, playflute | — |
| 15 | Forge | Custom: craft01, dustoff, forge01 | — |
| 16 | Guitar | Custom: bow, playguitar | — |
| 17 | Woodsman | Custom: *1attack01, kneelidle | — |
| 18 | Meditate | Custom: meditate | — |
| 19 | Post | Custom: lookleft, lookright | — |
| 20 | Read | Custom: sitidle, sitread, sitteat | — |
| 21 | Sit | Custom: sitfidget, sitidle, sittalk, sittalk01, sittalk02 | — |
| 22 | SitDinner | Custom: sitdrink, siteat, sitidle, sittalk, sittalk01, sittalk02 | — |
| 23 | StandChat | Custom: chuckle, lookleft, lookright, nodno, nodyes, shrug, talk01, talk02, talklaugh | — |
| 24 | TrainingOne | Custom: lookleft, lookright | требует партнёра |
| 25 | TrainingTwo | Custom: lookleft, lookright | требует партнёра |
| 26 | TrainerPace | Custom: lookleft, lookright | требует маршрут |
| 27 | WWP | Custom: kneelidle, lookleft, lookright | требует маршрут |
| 28 | Cheer | Custom: chuckle, clapping, talklaugh, victory | — |
| 29 | CookMulti | Custom: cooking01, cooking02, craft01, disablefront, dustoff, forge01, gettable, kneelidle, kneelup, openlock, scratchhead | — |
| 30 | ForgeMulti | Custom: craft01, dustoff, forge01, forge02, gettable, kneeldown, kneelidle, kneelup, openlock | — |
| 31 | Midnight90 | Custom: laydownB, proneB | — |
| 32 | Sleep90 | Custom: laydownB, proneB | — |
| 33 | Thief | Custom: chuckle, getground, gettable, openlock | — |
| 36 | Thief2 | Custom: disableground, sleightofhand, sneak | — |
| 37 | Assassin | Custom: sneak | — |
| 38 | MerchantMulti | Custom: bored, getground, gettable, openlock, sleightofhand, yawn | — |
| 39 | KneelTalk | Custom: kneelidle, kneeltalk | — |
| 41 | Barmaid | Custom: gettable, lookright, openlock, yawn | требует барную пару |
| 42 | Bartender | Custom: gettable, lookright, openlock, yawn | — |
| 43 | Guard | Custom: bored, lookleft, lookright, sigh | — |
| 91–98 | LocateWrapper | см. `al_acts_inc.nss` | — |
| 200 | reserved | — | — |

### Требования активностей

- **TrainingOne/TrainingTwo**: требует `al_training_partner`.
- **Barmaid**: требует `al_bar_pair` (Bartender).
- **TrainerPace**: требует маршрут.
- **WWP**: требует маршрут.

Если требование не выполнено, система подставит `ActOne`.

## Установка и подключение

1. Импортируйте все `.nss` файлы из `scripts/` в модуль.
2. Скомпилируйте модуль.
   - Include-файлы (`*_inc.nss`) пометьте как Include или исключите из компиляции.
   - Resref скриптов ≤ 16 символов (ограничение NWN2).
3. Подключите скрипты к событиям:

### События области (Area)

- OnEnter → `al_area_onenter`
- OnExit → `al_area_onexit`
- OnHeartbeat → оставить пустым

### События модуля (Module)

- OnClientLeave → `al_mod_onleave`

### События NPC

- OnSpawn → `al_npc_onspawn`
- OnDeath → `al_npc_ondeath`
- OnUserDefined → `al_npc_onud`

## Конфигурация NPC

Активность задаётся локальным int `al_activity` на waypoint.
Слоты `a0..a5` и роли не используются.

### Настройка маршрутов

- Для каждого NPC задайте локальные string:
  - `alwp0..alwp5` — тег маршрута для соответствующего слота.
- Если `alwp<slot>` не задан, используется `AL_WP_S<slot>` для обратной
  совместимости.

### Тренировочные партнёры

1. Назначьте NPC теги `FACTION_NPC1` и `FACTION_NPC2`.
2. На области задайте локальные object-переменные:
   - `al_training_npc1_ref`
   - `al_training_npc2_ref`

### Bartender + Barmaid

1. На области задайте локальные object-переменные:
   - `al_bar_bartender_ref`
   - `al_bar_barmaid_ref`

## Ограничения и риски

- **Лимит 100 NPC** на область (`AL_MAX_NPCS`). NPC сверх лимита не управляются.
- **Маршруты по слотам** кешируются и используются всегда, активность
  берётся с waypoint’а.
- Первый вход игрока в область вызывает **полный обход объектов**
  (кеширование маршрутов). В больших областях это может дать пик нагрузки.
- Система не использует heartbeat на NPC — это ожидаемое поведение.

## Проверка работоспособности

1. Запустите модуль.
2. Войдите PC в область:
   - NPC должны появиться и начать анимации.
3. Выйдите из области:
   - NPC должны скрыться.
4. Дождитесь смены слота суток:
   - NPC должны сменить активность на следующем waypoint’е.

Если что-то не работает, проверьте:

- назначение скриптов на события;
- локальный `al_activity` на waypoint’ах;
- наличие waypoint’ов;
- успешную компиляцию.

## Репозиторий

- `README.md` — этот документ.
- `ARCHITECTURE.md` — оригинальный дизайн-док (дублирован в README).
- `INSTALLATION.md` — простая инструкция (дублирована в README).
- `AUDIT.md` — аудит рисков (включён в раздел «Ограничения и риски»).
- `scripts/` — скрипты системы.
