# Zadanie 9: Fuzzy logika – Riadenie križovatky

##  Pevné riadenie s intervalom [10, 10, 10]

#### Režim 1

![Pevné intervaly – Režim 1](images/int_1.png)

- **Maximálny počet áut:** 16
- **Počet áut na konci:** 8
- **Maximá v pruhoch:** A1=2, A2=2, A3=2, B1=3, B2=3, C1=4, C2=2

#### Režim 2

![Pevné intervaly – Režim 2](images/int_2.png)

- **Maximálny počet áut:** 36
- **Počet áut na konci:** 31
- **Maximá v pruhoch:** A1=2, A2=2, A3=3, B1=6, B2=3, C1=6, C2=3

#### Režim 3

![Pevné intervaly – Režim 3](images/int_3.png)

- **Maximálny počet áut:** 25
- **Počet áut na konci:** 17
- **Maximá v pruhoch:** A1=2, A2=1, A3=3, B1=2, B2=2, C1=13, C2=6

#### Režim 4

![Pevné intervaly – Režim 4](images/int_4.png)

- **Maximálny počet áut:** 27
- **Počet áut na konci:** 18
- **Maximá v pruhoch:** A1=2, A2=2, A3=3, B1=13, B2=7, C1=2, C2=1

#### Režim 5

![Pevné intervaly – Režim 5](images/int_5.png)

- **Maximálny počet áut:** 39
- **Počet áut na konci:** 38
- **Maximá v pruhoch:** A1=11, A2=16, A3=11, B1=2, B2=1, C1=1, C2=3

#### Režim 6

![Pevné intervaly – Režim 6](images/int_6.png)

- **Maximálny počet áut:** 60
- **Počet áut na konci:** 57
- **Maximá v pruhoch:** A1=10, A2=18, A3=11, B1=12, B2=6, C1=9, C2=14

### tabuľka pre pevné riadenie

| Režim |  Max áut | Final áut |
|:-----:|:-------:|:---------:|
| 1 | 16 | 8 |
| 2 |  36 | 31 |
| 3 |  25 | 17 |
| 4 |  27 | 18 |
| 5 |  39 | 38 |
| 6 |  **60** | **57** |

---

## Fuzzy riadenie

###  Návrh fuzzy systému

**Vstupy:**
- `cars_green` – celkový počet áut na zelenej (rozsah `[0, 30]`)
- `cars_red` – celkový počet áut na červenej (rozsah `[0, 60]`)

**Výstup:**
- `duration` – doba trvania momentálnej konfigurácie semaforov (rozsah `[5, 30]` krokov)

###  Funkcie 

#### Vstup `cars_green` (počet áut na zelenej)

|hodnota | Typ | Parametre |
|---|---|---|
| `low` (málo) | trimf | [0, 0, 5] |
| `medium` (stredne) | trimf | [3, 7, 12] |
| `high` (veľa) | trimf | [8, 14, 30] |

#### Vstup `cars_red` (počet áut na červenej)

| hodnota | Typ | Parametre |
|---|---|---|
| `low` | trimf | [0, 3, 10] |
| `medium` | trimf | [5, 15, 30] |
| `high` | trimf | [15, 35, 60] |

#### Výstup `duration` (doba trvania zelenej)

|  hodnota | Typ | Parametre |
|---|---|---|
| `short` (krátko) | trimf | [5, 5, 12] |
| `medium` (normálne) | trimf | [10, 18, 25] |
| `long` (dlho) | trapmf | [20, 28, 30, 30] |

### Báza pravidiel

Fuzzy systém obsahuje **7 pravidiel**:

| # | Ak `cars_green` je... | a `cars_red` je... | potom `duration` je... |
|:-:|---|---|---|
| 1 | low | high | short |
| 2 | high | low | long |
| 3 | any | high | short |
| 4 | medium | medium | medium |
| 5 | medium | high | short |
| 6 | high | medium | long |
| 7 | low | low | medium |

###  Výsledky jednotlivých behov

#### Režim 1 

![Fuzzy – Režim 1](images/fuzzy_1.png)

- **Maximálny počet áut:** 16
- **Počet áut na konci:** 4
- **Maximá v pruhoch:** A1=2, A2=2, A3=2, B1=3, B2=3, C1=4, C2=2

#### Režim 2 

![Fuzzy – Režim 2](images/fuzzy_2.png)

- **Maximálny počet áut:** 23
- **Počet áut na konci:** 6
- **Maximá v pruhoch:** A1=7, A2=7, A3=6, B1=5, B2=4, C1=4, C2=5

#### Režim 3 

![Fuzzy – Režim 3](images/fuzzy_3.png)

- **Maximálny počet áut:** 21
- **Počet áut na konci:** 10
- **Maximá v pruhoch:** A1=2, A2=2, A3=3, B1=2, B2=2, C1=13, C2=6

#### Režim 4 

![Fuzzy – Režim 4](images/fuzzy_4.png)

- **Maximálny počet áut:** 20
- **Počet áut na konci:** 7
- **Maximá v pruhoch:** A1=2, A2=2, A3=3, B1=10, B2=6, C1=2, C2=1

#### Režim 5

![Fuzzy – Režim 5](images/fuzzy_5.png)

- **Maximálny počet áut:** 23
- **Počet áut na konci:** 8
- **Maximá v pruhoch:** A1=5, A2=12, A3=5, B1=2, B2=1, C1=2, C2=3

#### Režim 6

![Fuzzy – Režim 6](images/fuzzy_6.png)

- **Maximálny počet áut:** 33
- **Počet áut na konci:** 10
- **Maximá v pruhoch:** A1=7, A2=15, A3=7, B1=10, B2=7, C1=8, C2=8

### Súhrnná tabuľka pre fuzzy riadenie

| Režim | Max áut | Final áut |
|:-----:|:-------:|:---------:|
| 1 |  16 | 4 |
| 2 | 23 | 6 |
| 3 |  21 | 10 |
| 4 |  20 | 7 |
| 5 |  23 | 8 |
| 6 |  **33** | **10** |

---

##  Porovnanie pevného a fuzzy riadenia

###  Súhrnná porovnávacia tabuľka

| Režim | Pevné max | Pevné final | Fuzzy max | Fuzzy final | Δ max | Δ final |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 1 | 16 | 8 | 16 | 4 | 0 | **−4** |
| 2 | 36 | 31 | 23 | 6 | **−13** | **−25** |
| 3 | 25 | 17 | 21 | 10 | **−4** | **−7** |
| 4 | 27 | 18 | 20 | 7 | **−7** | **−11** |
| 5 | 39 | 38 | 23 | 8 | **−16** | **−30** |
| 6 | 60 | 57 | 33 | 10 | **−27** | **−47** |


### Porovnanie maximálnych hodnôt v pruhoch (režim 6)

| Pruh | Pevné | Fuzzy | Zlepšenie |
|:-:|:-:|:-:|:-:|
| A1 | 10 | **7** | −3 |
| A2 | 18 | **15** | −3 |
| A3 | 11 | **7** | −4 |
| B1 | 12 | **10** | −2 |
| B2 | 6 | 7 | +1 |
| C1 | 9 | 8 | −1 |
| C2 | 14 | **8** | **−6** |


###  Overenie limitov zo zadania pre režim 6

| Kritérium | Limit | Skutočnosť | Stav |
|---|---|:-:|:-:|
| A1 ≤ 10 áut | ≤ 10 | 7 | ✅ |
| A2 ≤ 15 áut | ≤ 15 | 15 | ✅ |
| A3 ≤ 10 áut | ≤ 10 | 7 | ✅ |
| B1 ≤ 10 áut | ≤ 10 | 10 | ✅ |
| B2 ≤ 10 áut | ≤ 10 | 7 | ✅ |
| C1 ≤ 10 áut | ≤ 10 | 8 | ✅ |
| C2 ≤ 10 áut | ≤ 10 | 8 | ✅ |
| Maximálny počet áut počas scenára | ≤ 40 | **33** | ✅ |
| Počet áut na konci scenára | < 20 | **10** | ✅ |


---


Kľúč úspechu spočíval v **bezpečnostnom pravidle č. 3** (`if cars_red is high then duration is short`), ktoré okamžite skracuje aktuálnu zelenú, len čo sa červené pruhy začnú preplňovať. Vďaka tomu sa stíhajú odbavovať aj pruhy, ktoré majú zelenú len v jednej z troch fáz cyklu (B1, C1).

Fuzzy logika sa ukázala ako **vhodný nástroj pre riadenie dopravy** – umožňuje formálne zachytiť ľudský úsudok („ak je tu veľa a tam málo, daj dlhú zelenú") a previesť ho na konkrétne číselné rozhodnutia bez potreby presného matematického modelu dopravnej situácie.
