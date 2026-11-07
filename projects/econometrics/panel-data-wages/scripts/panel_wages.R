# =============================================================================
# Wage determinants with panel data: pooled OLS, fixed and random effects
# Bipin Joshi — MSc Agricultural Economics, Humboldt-Universität zu Berlin
# Data: "wages.xlsx" (595 individuals x 7 years, Cornwell & Rupert PSID extract)
# =============================================================================

library(readxl)
library(plm)
library(lmtest)

wages <- read_excel("wages.xlsx", sheet = 1)

# 1. Panel structure and data checks
colSums(is.na(wages))
length(unique(wages$id)); length(unique(wages$t))

# Share of individuals whose value changes over time, per variable.
# Variables that never change within a person cannot be estimated with fixed effects.
vars <- setdiff(names(wages), c("id", "t"))
share_varying <- function(x, id) mean(tapply(x, id, function(z) length(unique(z)) > 1))
sapply(vars, function(v) share_varying(wages[[v]], wages$id))

pwages <- pdata.frame(wages, index = c("id", "t"))
pdim(pwages)

# 2. Estimators
f <- lwage ~ exp + wks + ed + fem + ms + union
m_pool <- plm(f, data = pwages, model = "pooling")
m_fe   <- plm(f, data = pwages, model = "within", effect = "individual")
m_re   <- plm(f, data = pwages, model = "random", effect = "individual")
summary(m_pool); summary(m_fe); summary(m_re)

# 3. Model selection
plmtest(m_pool, type = "bp")   # Breusch-Pagan LM: pooled OLS vs random effects
pFtest(m_fe, m_pool)           # F-test: pooled OLS vs fixed effects
phtest(m_fe, m_re)             # Hausman: fixed vs random effects
