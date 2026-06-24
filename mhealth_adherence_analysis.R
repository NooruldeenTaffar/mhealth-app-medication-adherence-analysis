# mHealth App Usage and Medication Adherence Analysis (R)
#
# Questions:
# 1. Does age differ across chronic conditions (asthma, diabetes, hypertension)?
# 2. Does medication adherence differ between sexes?
# 3. Does medication adherence vary with mHealth app usage frequency?
# 4. Does hospital admission length predict self-reported health (SF-36 score)?
#
# Data: "mHealth_assessmentdata_2025.csv" -- participant_id, sex, age, condition,
# mHealth_app_usage, medication_adherence, hospital_days, sf36_score.
# PGDip Introduction to Statistics module assessment.
# Note: the dataset is not included in this repo (student survey data).
# Place a copy at data/mHealth_assessmentdata_2025.csv to reproduce.
#
# Approach: for each question, check the relevant distributional assumption
# (normality via histogram/QQ plot, or homoscedasticity for the regression)
# before choosing a parametric or non-parametric test.

library(tidyverse)
library(broom)
library(car)  # for leveneTest (homogeneity of variance check before ANOVA)

# ---- Load and inspect -----------------------------------------------------

df <- read.csv("data/mHealth_assessmentdata_2025.csv")
head(df)
str(df)
summary(df)
colSums(is.na(df))  # check for missing values before analysis

ggplot(df, aes(x = age)) +
  geom_histogram(binwidth = 5, fill = "blue", color = "black", alpha = 0.7) +
  labs(title = "Age Distribution of Participants", x = "Age (years)", y = "Count") +
  theme_minimal()

# =====================================================================
# Question 1: Does age differ across chronic conditions?
# =====================================================================

# ---- Assumption check: normality of age within each condition ------------

ggplot(df, aes(x = age)) +
  geom_histogram(binwidth = 5, fill = "blue", color = "black", alpha = 0.7) +
  facet_wrap(~ condition) +
  labs(title = "Age Distribution by Condition", x = "Age (years)", y = "Count") +
  theme_minimal()

ggplot(df, aes(sample = age)) +
  stat_qq() +
  stat_qq_line(color = "red") +
  facet_wrap(~ condition) +
  labs(title = "QQ Plot of Age by Condition") +
  theme_minimal()

# Age looks approximately normal within each condition group, so a
# parametric test (one-way ANOVA) is used. ANOVA also assumes equal
# variances across groups -- checked with Levene's test below.

leveneTest(age ~ condition, data = df)

anova_age <- aov(age ~ condition, data = df)
summary(anova_age)

# Finding: F(2, 8951) = 2.98, p = 0.051 -- borderline, not significant at
# the 0.05 level. Age does not differ meaningfully across conditions.

# =====================================================================
# Question 2: Does medication adherence differ between sexes?
# =====================================================================

ggplot(df, aes(x = medication_adherence)) +
  geom_histogram(binwidth = 5, fill = "purple", color = "black", alpha = 0.7) +
  labs(title = "Distribution of Medication Adherence", x = "Medication Adherence (%)", y = "Count") +
  theme_minimal()

ggplot(df, aes(sample = medication_adherence)) +
  stat_qq() +
  stat_qq_line(color = "red") +
  labs(title = "QQ Plot of Medication Adherence") +
  theme_minimal()

# Medication adherence is not clearly normally distributed, so a
# non-parametric test is used instead of a t-test.

wilcox_result <- wilcox.test(medication_adherence ~ sex, data = df)
wilcox_result

# Finding: W = 9,885,033, p = 0.264 -- no significant difference in
# medication adherence between males and females.

# =====================================================================
# Question 3: Does medication adherence vary with mHealth app usage?
# =====================================================================

ggplot(df, aes(x = medication_adherence, fill = mHealth_app_usage)) +
  geom_histogram(binwidth = 5, alpha = 0.6, position = "identity") +
  facet_wrap(~ mHealth_app_usage) +
  labs(
    title = "Medication Adherence Across mHealth App Usage Groups",
    x = "Medication Adherence (%)", y = "Count"
  ) +
  theme_minimal()

# Adherence looks roughly normal within each app-usage group, so ANOVA is used.

leveneTest(medication_adherence ~ mHealth_app_usage, data = df)

anova_adherence <- aov(medication_adherence ~ mHealth_app_usage, data = df)
summary(anova_adherence)

# Finding: F(3, 8950) = 29,854, p < 2e-16 -- medication adherence differs
# significantly across app-usage categories.

# =====================================================================
# Question 4: Does hospital admission length predict self-reported health?
# =====================================================================

ggplot(df, aes(x = hospital_days, y = sf36_score)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_smooth(method = "lm", se = TRUE, color = "red") +
  labs(
    title = "Relationship Between Hospital Days and SF-36 Health Score",
    x = "Hospital Days", y = "SF-36 Health Score"
  ) +
  theme_minimal()

model_simple <- lm(sf36_score ~ hospital_days, data = df)
summary(model_simple)

# Finding: intercept ~49.69, slope ~-1.62 (both p < 2e-16) -- each additional
# hospital day is associated with a ~1.62-point drop in SF-36 score.

# ---- Regression assumption checks ------------------------------------------

ggplot(data.frame(resid = residuals(model_simple)), aes(x = resid)) +
  geom_histogram(fill = "skyblue", color = "white", bins = 20, alpha = 0.8) +
  labs(title = "Histogram of Regression Residuals", x = "Residuals", y = "Frequency") +
  theme_minimal()

ggplot(data.frame(resid = residuals(model_simple)), aes(sample = resid)) +
  stat_qq() +
  stat_qq_line(color = "red") +
  labs(title = "QQ Plot of Regression Residuals") +
  theme_minimal()

ggplot(
  data.frame(fitted = fitted(model_simple), resid = residuals(model_simple)),
  aes(x = fitted, y = resid)
) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Residuals vs. Fitted Values", x = "Fitted SF-36 Scores", y = "Residuals") +
  theme_minimal()

# Residual histogram and QQ plot are roughly normal/diagonal, and the
# residuals-vs-fitted plot shows no clear funnel shape, supporting the
# regression's normality and homoscedasticity assumptions.
