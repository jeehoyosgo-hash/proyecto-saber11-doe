# Borrador de apoyo — el flujo completo y reproducible está en:
#   Proyecto_Saber11_DOE_final.Rmd
#
# Resumen del cambio (Opción A — MASE real):
#   1) API agregada: $select + $group por fami_estratovivienda → N_h y N = sum(N_h)
#   2) n con corrección finita usando ese N
#   3) Afijación proporcional (restos mayores) → n_h por estrato
#   4) Por cada estrato: SoQL ORDER BY random() LIMIT n_h, o respaldo $where + slice_sample
#   5) survey::svydesign con strata, fpc = N_h y weights = N_h / n_h en la muestra
#
# Fases III–VII (factorial, 2^k, bloques, PPS, encuesta compleja): solo en Proyecto_Saber11_DOE_final.Rmd

library(httr)
library(dplyr)

url_api <- "https://www.datos.gov.co/resource/kgxf-xxbe.csv"

# --- Marco N_h (misma consulta que el .Rmd) ---------------------------------
aggr_txt <- content(
  GET(
    url_api,
    query = list(
      "$select" = "fami_estratovivienda, count(*)",
      "$group"  = "fami_estratovivienda",
      "$limit"  = "100000"
    )
  ),
  as = "text",
  encoding = "UTF-8"
)
tabla_marco_raw <- read.csv(text = aggr_txt, stringsAsFactors = FALSE, check.names = FALSE)
names(tabla_marco_raw)[1:2] <- c("fami_estratovivienda", "Nh")
tabla_marco_estratos <- tabla_marco_raw %>%
  filter(!is.na(fami_estratovivienda), fami_estratovivienda != "") %>%
  mutate(Nh = as.numeric(Nh)) %>%
  filter(Nh > 0)

N_frame <- sum(tabla_marco_estratos$Nh)
cat("N marco (API):", format(N_frame, big.mark = ","), "\n")

# --- Piloto y n (igual que en el informe) -----------------------------------
url_piloto <- "https://www.datos.gov.co/resource/kgxf-xxbe.csv?$limit=300&$offset=0"
piloto <- read.csv(text = content(GET(url_piloto), as = "text", encoding = "UTF-8"),
                   stringsAsFactors = FALSE)
piloto$punt_global <- as.numeric(piloto$punt_global)
piloto <- piloto[!is.na(piloto$punt_global), ]

Z  <- 1.96
e  <- 3
S2 <- var(piloto$punt_global)
N  <- N_frame
n_inf   <- (Z^2 * S2) / e^2
n_final <- ceiling(n_inf / (1 + (n_inf / N)))
cat("n_final calculado:", n_final, "\n")

cat("\nPara la descarga estratificada completa, renderizar el .Rmd (varias peticiones HTTP).\n")
