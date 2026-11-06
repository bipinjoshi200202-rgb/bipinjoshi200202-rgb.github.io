# =============================================================================
# Stochastic Frontier Analysis of sunflower production
# Bipin Joshi — MSc Agricultural Economics, Humboldt-Universität zu Berlin
#
# Cobb–Douglas production frontier with half-normal inefficiency (sfaR),
# technical-efficiency scores, and determinants of inefficiency.
# Data: course dataset "dataSunFlower.RDS" (826 farms; not redistributed here).
# =============================================================================

library(dplyr)
library(ggplot2)
library(car)     # linearHypothesis()
library(sfaR)    # sfacross(), efficiencies()
library(lmtest)  # lrtest()

# --- 1. Data -----------------------------------------------------------------
df <- readRDS("dataSunFlower.RDS")

df <- df %>%
  rename(qt = Total_prod, lnd = Land, cap = Capital, lab = Labor, fert = Fertilizer) %>%
  mutate(across(c(region, gender, policy), as.factor))

# Logs require strictly positive values and no missing data
stopifnot(all(sapply(df[, c("qt", "lnd", "cap", "lab", "fert")], min) > 0))

# Mean-normalised logs: coefficients are elasticities at the sample mean
df <- df %>%
  mutate(qt_ln   = log(qt   / mean(qt)),
         lnd_ln  = log(lnd  / mean(lnd)),
         cap_ln  = log(cap  / mean(cap)),
         lab_ln  = log(lab  / mean(lab)),
         fert_ln = log(fert / mean(fert)))

# --- 2. Baseline: Cobb–Douglas by OLS ---------------------------------------
f_cd   <- qt_ln ~ lnd_ln + cap_ln + lab_ln + fert_ln
ols_cd <- lm(f_cd, data = df)
summary(ols_cd)

# Returns to scale and test of constant returns (H0: sum of elasticities = 1)
sum(coef(ols_cd)[c("lnd_ln", "cap_ln", "lab_ln", "fert_ln")])
linearHypothesis(ols_cd, "lnd_ln + cap_ln + lab_ln + fert_ln = 1")

# --- 3. Stochastic production frontier (half-normal) -------------------------
# epsilon = v - u,  v ~ N(0, sigma_v^2),  u ~ |N(0, sigma_u^2)|
sfa_cd <- sfacross(formula = f_cd, data = df, udist = "hnormal", S = 1L)
summary(sfa_cd)

# --- 4. Technical efficiency (Battese–Coelli) --------------------------------
df$te_bc <- efficiencies(sfa_cd)$teBC
summary(df$te_bc)

ggplot(df, aes(te_bc)) +
  geom_histogram(binwidth = 0.025, boundary = 0, colour = "white") +
  geom_vline(xintercept = mean(df$te_bc), linetype = "dashed") +
  labs(x = "Technical efficiency", y = "Number of farms",
       title = "Distribution of technical efficiency scores") +
  theme_bw()

# --- 5. Determinants of inefficiency (heteroscedastic u) ---------------------
sfa_cd_z <- sfacross(formula = f_cd, data = df, udist = "hnormal", S = 1L,
                     uhet = ~ Age + Age2 + gender + policy)
summary(sfa_cd_z)

# Do the inefficiency determinants improve the model?
lrtest(sfa_cd, sfa_cd_z)
