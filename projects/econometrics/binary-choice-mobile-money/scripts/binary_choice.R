# =============================================================================
# Mobile money adoption: linear probability, logit and probit models
# Bipin Joshi — MSc Agricultural Economics, Humboldt-Universität zu Berlin
# Data: course dataset "mobile_money.rds" (1,000 individuals; not redistributed)
# =============================================================================

library(tidyverse)
library(margins)  # average marginal effects
library(pscl)     # pseudo R-squared

df <- readRDS("mobile_money.rds")
table(df$adopt, useNA = "ifany")   # outcome distribution: only 8 adopters

f <- adopt ~ income + gender + age + student

# 1. Linear probability model
lpm <- lm(f, data = df)
summary(lpm)

# 2. Logit
model_logit <- glm(f, data = df, family = binomial(link = "logit"))
summary(model_logit)
summary(margins(model_logit))      # average marginal effects

# 3. Probit
model_probit <- glm(f, data = df, family = binomial(link = "probit"))
summary(model_probit)
summary(margins(model_probit))

# 4. Goodness of fit
pR2(model_logit)
pR2(model_probit)
