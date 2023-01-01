#
#
#

library(brms)
options("mc.cores" = 4)
options("brms.backend" = "cmdstanr")

load(file = file.path("data", "processed", "MD2021DHS.rda"))



# define binomial model with nested logit random effects
# include urban / rural classification by survey design

mod = brm(
  formula = stunted ~ urban + (1|region) + (1|gr(clusterid, by = region)) 
  , data = surveydata
  , family = bernoulli(link = "logit")
  , prior = NULL
  , file = file.path("models", "gxwmxatz")
)

summary(mod)
