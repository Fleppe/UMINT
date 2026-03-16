# Optimalizácia investičného portfólia pomocou genetického algoritmu


## Parametre genetického algoritmu

| Parameter | Hodnota |
|---|---|
| Veľkosť populácie | 100 |
| Počet generácií | 2500 |
| Počet behov | 5 |
| Rozsah premenných | 0 – 10 000 000 |

---

## Metóda 1 – Mŕtva pokuta

Pri mŕtvej pokute dostane riešenie veľkú fixnú penalizáciu, ak poruší niektoré obmedzenie. Neprípustné riešenia sú preto rýchlo vyradené z evolúcie.

### Graf konvergencie

![Dead penalty convergence](dead_penalty.png)

### Výsledky jednotlivých behov

| Run | Finálna fitness | Výnos |
|---|---|---|
| 1 | ... | ... |
| 2 | ... | ... |
| 3 | ... | ... |
| 4 | ... | ... |
| 5 | ... | ... |

### Najlepší jedinec

| Premenná | Hodnota |
|---|---|
| x1 | ... |
| x2 | ... |
| x3 | ... |
| x4 | ... |
| x5 | ... |

---

## Metóda 2 – Stupňovitá pokuta

Pri stupňovitej pokute závisí penalizácia od počtu porušených obmedzení. Čím viac obmedzení riešenie poruší, tým väčšiu pokutu dostane.

### Graf konvergencie

![Step penalty convergence](step_penalty.png)

### Výsledky jednotlivých behov

| Run | Finálna fitness | Výnos |
|---|---|---|
| 1 | ... | ... |
| 2 | ... | ... |
| 3 | ... | ... |
| 4 | ... | ... |
| 5 | ... | ... |

### Najlepší jedinec

| Premenná | Hodnota |
|---|---|
| x1 | ... |
| x2 | ... |
| x3 | ... |
| x4 | ... |
| x5 | ... |

---

## Metóda 3 – Úmerná pokuta

Pri úmernej pokute je penalizácia priamo úmerná miere porušenia obmedzenia. Riešenia, ktoré sú bližšie k prípustnej oblasti, dostávajú menšiu pokutu.

### Graf konvergencie

![Proportional penalty convergence](proportional_penalty.png)

### Výsledky jednotlivých behov

| Run | Finálna fitness | Výnos |
|---|---|---|
| 1 | ... | ... |
| 2 | ... | ... |
| 3 | ... | ... |
| 4 | ... | ... |
| 5 | ... | ... |

### Najlepší jedinec

| Premenná | Hodnota |
|---|---|
| x1 | ... |
| x2 | ... |
| x3 | ... |
| x4 | ... |
| x5 | ... |

---

## Porovnanie metód

Porovnaním troch metód pokutovania je možné pozorovať rozdiely v rýchlosti konvergencie aj v stabilite výsledkov medzi jednotlivými behmi.

- **Mŕtva pokuta** rýchlo eliminuje neprípustné riešenia, ale môže obmedziť prehľadávanie priestoru riešení.
- **Stupňovitá pokuta** poskytuje lepšie rozlíšenie medzi rôznymi stupňami porušenia obmedzení.
- **Úmerná pokuta** poskytuje najjemnejšiu spätnú väzbu genetickému algoritmu a často vedie k stabilnejšej konvergencii.

---

## Záver

Genetický algoritmus dokázal nájsť optimálne alebo veľmi dobré investičné portfólio pri dodržaní všetkých obmedzení.

Výsledky ukazujú, že spôsob penalizácie má významný vplyv na:

- rýchlosť konvergencie
- stabilitu medzi jednotlivými behmi
- kvalitu výsledného riešenia.