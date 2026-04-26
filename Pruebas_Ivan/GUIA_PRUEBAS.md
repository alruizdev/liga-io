# 🧪 Laboratorio de Pruebas - Interóptimo de Lagrange

Este documento explica el propósito de cada script de MATLAB desarrollado. No solo buscamos "un buen equipo", sino que usamos técnicas de **Investigación Operativa** para demostrar que nuestra elección es la más robusta matemáticamente.

---

## 🚀 1. Motores de Optimización (Buscadores)

Estos scripts exploran el espacio de soluciones para encontrar el equipo con el Win-Rate (WR) más alto.

* **`Busqueda_equip_Perfecto.m`**: Es nuestra "Artillería Pesada". Combina un **Algoritmo Genético (GA)** para explorar globalmente y un **Recocido Simulado (SA)** para pulir los detalles. Es el que usamos para las búsquedas largas (Overnight).
* **`buscador_pso.m`**: Implementa **Optimización por Enjambre de Partículas**. Los equipos "vuelan" hacia el mejor resultado compartiendo información. Es muy rápido convergiendo hacia valores de Eficacia y Técnico altos.
* **`buscador_tabu.m`**: Usa **Búsqueda Tabú**. Es una búsqueda local inteligente que "prohíbe" volver a configuraciones anteriores para no quedarse atrapado en un máximo local (una falsa cima).
* **`BuscadorEquipo_v2.m`**: Nuestra versión optimizada de **Fuerza Bruta**. Genera miles de equipos válidos al azar. Es útil para descubrir "rarezas" tácticas que los algoritmos dirigidos podrían ignorar.

---

## 🔍 2. Auditoría y Análisis de Riesgo

Scripts diseñados para "romper" el modelo y encontrar sus debilidades antes que el profesor.

* **`cazador_mitos.m`**: Comprueba si lo que dijo el profesor en clase es cierto. Enfrenta equipos de 100 puntos contra 95 para ver si la "ventaja de underdog" compensa perder 5 puntos de stats. También mide el castigo real por **Dispersión** (alejar los números del 10).
* **`analisis.m`**: Realiza un **Análisis de Varianza**. No se queda con un solo dato de Win-Rate; simula 100 ligas enteras para dibujar una **Campana de Gauss**. Nos dice cuánto dependemos de la suerte (P5 y P95).

---

## 📊 3. Resultados y Datos (.mat)

* **`01.mat`**: El vector "Elegido" para la Liga. Suma 100, sin ceros.
* **`campeon_torneo.mat`**: El ganador de una liga privada donde enfrentamos a los mejores equipos de cada algoritmo entre sí.

---

## 🛠️ Notas Técnicas para el Grupo
- **Rutas**: Todos los archivos usan `addpath(genpath(fileparts(mfilename('fullpath'))))`. Esto significa que funcionan en cualquier ordenador sin cambiar rutas.
- **Simulador**: Asegúrate de tener `playMatch.p` en la carpeta para que los scripts puedan usar el motor oficial del profesor.