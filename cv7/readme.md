# MLP - MNIST dataset


## Parametre

| Model | Skryté vrstvy | Neurony |LR | Epochy | podiel T:V | Skore ukoncenie | 
|---|---|---|---|---|---|---|
| MLP1 | 1 | 256 | 0.01 | 300 | 80:20 | 20
| MLP2 |  2 | 256 128| 0.01 | 300 | 80:20 | 20
---


## Behy
### MLP1
| Beh | Trenovacia presnost | Testovacia presnost | train loss| test loss |
|---|---| ---|---|---|
| 1 | 99.8 | 97.5 | 0.0015|  0.009|
| 2 | 99.7 | 97.4 | 0.0016| 0.0095|
| 3 | 99.6 | 97.2 | 0.0030 | 0.010|
| 4 | 99.8 | 97.5|  0.0012|  0.0088|
| 5 | 99.5 |97.3 |  0.0020 |0.0097 |

---
### MLP2
| Run | Trenovacia presnost |  Testovacia presnost |  train loss| test loss |
|---|---| ---| ---| ---|
| 1 | 99.5 | 97.2 |0.0019 | 0.0096 |
| 2 | 99.8 | 97.5 |0.0012 | 0.0091 |
| 3 | 99.4 | 97.3 |0.0023 | 0.010 |
| 4 | 99.6 | 97.1|0.0016 | 0.0103 |
| 5 | 98.9 |97.2 |0.0036 | 0.0096 |

---

---
## Zhodnotenie
| Model | Min test| Max test|  Priemer test| Priemer loss |
|---|---| ---|---|---|
| M1 | 97.2 | 97.5 | 97.38 | 0.0094 |
| M2  |  97.1 | 97.5 | 97.26 | 0.00972 |


---
## Matice zámien
![MLP1](img/conf1_1.png)

---
![MLP2](img/conf2_1.png)

---

## Grafy loss-epoch priebehu
![MLP1](img/perf1_1.png)
![MLP2](img/perf2_1.png)

## Vykreslenie vybraných vzoriek
![Vzorky pre MLP1](img/MLP1_1.png)
![Vzorky pre MLP2](img/MLP2_1.png)




