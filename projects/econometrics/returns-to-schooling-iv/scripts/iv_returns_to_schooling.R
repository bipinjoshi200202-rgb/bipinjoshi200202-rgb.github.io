# =============================================================================
# Returns to schooling with an instrumental variable (college proximity)
# Bipin Joshi — MSc Agricultural Economics, Humboldt-Universität zu Berlin
# Data: Card (1995) NLS Young Men extract, "card.rds"
# =============================================================================

library(AER)   # ivreg()

data <- readRDS("card.rds")

# A. OLS (schooling treated as exogenous)
model_ols <- lm(lwage76 ~ ed76 + black + daded + momed + famed + south66, data = data)
summary(model_ols)

# B. First stage: does growing up near a 4-year college predict schooling?
first_stage <- lm(ed76 ~ nearc4 + black + daded + momed + famed + south66, data = data)
summary(first_stage)
anova(first_stage)   # F-test for instrument strength

# C. Reduced form: effect of the instrument directly on wages
reduced_form <- lm(lwage76 ~ nearc4 + black + daded + momed + famed + south66, data = data)
summary(reduced_form)

# D. 2SLS
model_iv <- ivreg(
  lwage76 ~ ed76 + black + daded + momed + famed + south66 |
    nearc4 + black + daded + momed + famed + south66,
  data = data
)
summary(model_iv, diagnostics = TRUE)   # weak-instrument and Wu-Hausman tests

# Compare the return to schooling
summary(model_ols)$coefficients["ed76", ]
summary(model_iv)$coefficients["ed76", ]
