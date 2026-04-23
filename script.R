# Instalar si no tienes
install.packages("httr")
install.packages("jsonlite")

library(httr)
library(jsonlite)

# Descarga 000 registros via API Socrata (ICFES datos.gov.co)
url <- "https://www.datos.gov.co/resource/kgxf-xxbe.csv?$limit=10000&$offset=0"

res <- GET(url)
datos_raw <- content(res, as = "text", encoding = "UTF-8")
icfes <- read.csv(text = datos_raw, stringsAsFactors = FALSE)

# Ver estructura
dim(icfes)
head(icfes)
names(icfes)

library(httr)
library(jsonlite)

# ── PASO 1: Muestra piloto para estimar varianza ──────────────────────────
url_piloto <- "https://www.datos.gov.co/resource/kgxf-xxbe.csv?$limit=300&$offset=0"
piloto <- read.csv(text = content(GET(url_piloto), as = "text", encoding = "UTF-8"))

# Limpiar punt_global (convertir a numérico)
piloto$punt_global <- as.numeric(piloto$punt_global)
piloto <- piloto[!is.na(piloto$punt_global), ]

# Ver varianza y media del piloto
cat("Media piloto:", mean(piloto$punt_global), "\n")
cat("Varianza piloto (S²):", var(piloto$punt_global), "\n")
cat("Desv. estándar:", sd(piloto$punt_global), "\n")

# ── PASO 2: Cálculo del tamaño de muestra (MAS con población grande) ──────
# Supuestos que vamos a justificar en el informe:
Z    <- 1.96       # 95% de confianza
e    <- 3          # margen de error: 3 puntos en escala Saber 11
S2   <- var(piloto$punt_global)
N    <- 7109704    # población total (lo viste en datos.gov.co)

n_infinito <- (Z^2 * S2) / e^2
n_final    <- ceiling(n_infinito / (1 + (n_infinito / N)))
n_final

cat("\n── Cálculo del tamaño de muestra ──\n")
cat("n sin corrección finita:", ceiling(n_infinito), "\n")
cat("n con corrección finita:", n_final, "\n")

library(dplyr)

# ── PASO 3: Descarga de la muestra completa (n=841) ───────────────────────
url_muestra <- "https://www.datos.gov.co/resource/kgxf-xxbe.csv?$limit=841&$offset=300"
# offset=300 para no repetir el piloto

muestra_raw <- read.csv(text = content(GET(url_muestra), 
                                       as = "text", encoding = "UTF-8"))

# Limpiar variables clave
muestra <- muestra_raw %>%
  mutate(
    punt_global      = as.numeric(punt_global),
    fami_estratovivienda = as.factor(fami_estratovivienda),
    cole_naturaleza  = as.factor(cole_naturaleza),
    cole_calendario  = as.factor(cole_calendario),
    cole_jornada     = as.factor(cole_jornada)
  ) %>%
  filter(!is.na(punt_global))

# ── PASO 4: Verificar distribución por estrato (variable de estratificación)
cat("Distribución por estrato socioeconómico:\n")
print(table(muestra$fami_estratovivienda))

cat("\nDistribución por naturaleza del colegio:\n")
print(table(muestra$cole_naturaleza))

cat("\nDistribución por calendario:\n")
print(table(muestra$cole_calendario))

cat("\nResumen de punt_global:\n")
print(summary(muestra$punt_global))


cat("Distribución por jornada:\n")
print(table(muestra$cole_jornada))

cat("\nCombinación naturaleza x jornada:\n")
print(table(muestra$cole_naturaleza, muestra$cole_jornada))

# ── Filtrar para DBCA: 3 jornadas con balance aceptable ──────────────────
dbca_data <- muestra %>%
  filter(cole_jornada %in% c("MAÑANA", "COMPLETA", "NOCHE")) %>%
  filter(!is.na(punt_global)) %>%
  droplevels()

cat("Tabla de balance tras filtro:\n")
print(table(dbca_data$cole_naturaleza, dbca_data$cole_jornada))

cat("\nTotal observaciones para DBCA:", nrow(dbca_data), "\n")

cat("\nMedia de punt_global por naturaleza:\n")
print(tapply(dbca_data$punt_global, dbca_data$cole_naturaleza, mean))

cat("\nMedia de punt_global por jornada:\n")
print(tapply(dbca_data$punt_global, dbca_data$cole_jornada, mean))

