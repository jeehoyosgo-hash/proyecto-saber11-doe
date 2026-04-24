# Proyecto Investigativo — Saber 11: Muestreo & Diseño de Experimentos

**Universidad Santo Tomás · Estadística V Semestre · 2026-I**
Julián Toloza · Yeison Hoyos

---

## Descripción

Análisis integrado de **muestreo estadístico** y **diseño de experimentos** sobre los resultados de la prueba Saber 11 (ICFES). El proyecto responde la pregunta:

> *¿Difiere el puntaje global Saber 11 según la naturaleza del colegio (oficial vs. no oficial), controlando por la jornada escolar como variable de bloque?*

**Fuente de datos:** [Resultados únicos Saber 11 — Datos Abiertos Colombia](https://www.datos.gov.co/resource/kgxf-xxbe) · N = 7,109,704 registros

---

## Resultados principales

| Indicador | Valor |
|---|---|
| Tamaño de muestra (n) | 841 — calculado con Z=1.96, e=±3 pts, S²=1968.5 |
| Puntaje global estimado | 250.74 pts — IC 95%: [246.42, 255.06] |
| Diseño experimental | DBCA — Bloques Completos al Azar |
| F tratamiento (naturaleza) | 53.7 — p = 1.88×10⁻¹² |
| F bloque (jornada) | 16.1 — p = 2.16×10⁻⁷ |
| Diferencia NO OFICIAL vs OFICIAL | +41.1 pts (Tukey IC: [30.1, 52.1]) |
| Potencia del diseño | ~99% |

---

## Archivos del proyecto

```
proyecto-saber11-doe/
│
├── Proyecto_Saber11_DOE.Rmd          # Notebook reproducible — entregable principal
├── Proyecto_Saber11_DOE.html         # Informe renderizado
│
├── dashboard_saber11.html            # Dashboard de presentación (sustentación)
├── simulador_estadistico.html        # Simulador interactivo para la sustentación
│
└── README.md
```

### Descripción de cada archivo

**`Proyecto_Saber11_DOE.Rmd`** — Informe técnico completo en R Markdown. Incluye:
- Fase I: Muestreo estratificado por estrato socioeconómico con paquete `survey`
- Fase II: DBCA con verificación de supuestos (Lilliefors, Levene, Tukey HSD)
- Estimador de razón y comparación de eficiencia
- Declaración de uso de inteligencia artificial

**`dashboard_saber11.html`** — Dashboard visual para presentar los resultados durante la sustentación. 5 secciones navegables: Inicio, Fase I, Fase II, Supuestos y Conclusiones. Abre directamente en el navegador, sin necesidad de R ni internet.

**`simulador_estadistico.html`** — Simulador interactivo con 4 pestañas:
- **Muestreo:** botones de confianza (90/95/99%) y slider de error → recalcula n en tiempo real
- **ANOVA & DBCA:** slider de réplicas → actualiza tabla ANOVA y descomposición de varianza
- **Potencia:** slider de n y botones de α → curva potencia vs n
- **Comparador:** diseño real vs escenarios hipotéticos (DCA vs DBCA, MAS vs estratificado)

---

## Tecnologías utilizadas

| Herramienta | Uso |
|---|---|
| R / R Markdown | Análisis estadístico y entregable principal |
| `survey` | Diseño muestral estratificado con pesos |
| `car`, `nortest`, `emmeans` | Verificación de supuestos y comparaciones múltiples |
| HTML5 + CSS3 + JavaScript | Dashboard y simulador interactivos |
| Chart.js | Visualizaciones del simulador |

---

## Cómo reproducir el análisis

```r
# 1. Instalar paquetes necesarios
install.packages(c("httr", "dplyr", "ggplot2", "survey",
                   "emmeans", "car", "nortest", "knitr", "kableExtra"))

# 2. Abrir Proyecto_Saber11_DOE.Rmd en RStudio
# 3. Hacer clic en Knit → Knit to HTML
# Los datos se descargan automáticamente desde la API del ICFES
```

> Los datos se obtienen en tiempo real desde `https://www.datos.gov.co/resource/kgxf-xxbe.csv` mediante la API Socrata. No se incluyen archivos de datos locales.

---

## Metodología resumida

**Fase I — Muestreo:**
1. Muestra piloto (n=300) → estimación de S²=1968.5
2. Cálculo de n=841 con fórmula MAS y corrección finita (Z=1.96, e=±3)
3. Muestreo estratificado por estrato socioeconómico con asignación proporcional
4. Estimación con `svymean` → media=250.74, IC=[246.42, 255.06]
5. Estimador de razón (lectura/matemáticas) → CV=0.78% vs 0.88% del estimador simple

**Fase II — Diseño experimental:**
1. DBCA: naturaleza del colegio (tratamiento) × jornada escolar (bloque)
2. ANOVA: F=53.7, p=1.88×10⁻¹² → se rechaza H₀
3. Supuestos: normalidad (Lilliefors D=0.052, robusto por TCL con n=327), homocedasticidad cumplida (Levene p=0.186)
4. Tukey HSD: diferencia=-41.1 pts, IC=[-52.1, -30.1]

---

## Referencias

- Lohr, S. L. (2022). *Sampling: Design and Analysis* (3rd ed.). CRC Press.
- Montgomery, D. C. (2017). *Design and Analysis of Experiments* (9th ed.). Wiley.
- ICFES. (2025). *Resultados únicos Saber 11*. Datos Abiertos Colombia.
- R Core Team. (2024). *R: A Language and Environment for Statistical Computing*.
- Lumley, T. (2023). *survey: Analysis of Complex Survey Samples* (R package v4.2).

---

## Declaración de uso de IA

Este proyecto utilizó **Claude (Anthropic)** como herramienta de asistencia en exploración de datos, generación de código R y construcción de los archivos HTML del dashboard y simulador. Todas las decisiones metodológicas fueron verificadas por el equipo contrastándolas con los módulos del curso y la bibliografía oficial.
