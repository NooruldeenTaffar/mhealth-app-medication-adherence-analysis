# mHealth App Usage and Medication Adherence Analysis

Statistical analysis of a survey dataset (n = 8,954) exploring how mobile health (mHealth) app usage relates to medication adherence and health outcomes in patients with chronic conditions (asthma, diabetes, hypertension).

Originally completed as the statistics module assessment for the PGDip in Data Science for Health & Social Care (University of Edinburgh). Reworked here into a standalone, reproducible R script.

## Research Questions

1. Does age differ across chronic conditions?
2. Does medication adherence differ between sexes?
3. Does medication adherence vary with mHealth app usage frequency?
4. Does length of hospital admission predict self-reported health (SF-36 score)?

## Methods

Each question follows the same approach: check the relevant distributional assumption first (normality via histogram/QQ plot, homogeneity of variance via Levene's test, or homoscedasticity of residuals for the regression), then choose a parametric or non-parametric test accordingly.

- **Q1**: One-way ANOVA (age ~ condition)
- **Q2**: Wilcoxon rank-sum test (medication_adherence ~ sex) — used instead of a t-test since adherence wasn't normally distributed
- **Q3**: One-way ANOVA (medication_adherence ~ mHealth_app_usage)
- **Q4**: Simple linear regression (sf36_score ~ hospital_days), with residual diagnostics

## Key Findings

| Question | Result |
|---|---|
| Age vs. condition | F(2, 8951) = 2.98, p = 0.051 — no significant difference |
| Adherence vs. sex | W = 9,885,033, p = 0.264 — no significant difference |
| Adherence vs. app usage | F(3, 8950) = 29,854, p < 2e-16 — highly significant |
| Hospital days vs. SF-36 | slope ≈ −1.62, p < 2e-16 — each extra hospital day predicts a ~1.6-point drop in self-reported health |

The standout result is the strong association between mHealth app usage frequency and medication adherence, consistent with the idea that more frequent app engagement supports better adherence behaviour.

## Skills Demonstrated

- Hypothesis testing and assumption checking (normality, homogeneity of variance, homoscedasticity)
- Parametric and non-parametric test selection (ANOVA, Wilcoxon rank-sum, linear regression)
- Data visualisation with `ggplot2` (histograms, QQ plots, residual diagnostics, scatter plots with fitted lines)
- Reproducible analysis workflow in R (`tidyverse`, `broom`, `car`)
- Translating clinical/health survey data into actionable statistical findings

## Data

The dataset (`mHealth_assessmentdata_2025.csv`) is coursework survey data and is not included in this repo. To reproduce, place a copy at `data/mHealth_assessmentdata_2025.csv` — expected columns: `participant_id`, `sex`, `age`, `condition`, `mHealth_app_usage`, `medication_adherence`, `hospital_days`, `sf36_score`.

## Files

- `mhealth_adherence_analysis.R` — full analysis script
