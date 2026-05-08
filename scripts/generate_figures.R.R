############################################################
# Figuras para el proyecto de predicción mutacional
# de grado tumoral en gliomas
############################################################

# 1. Paquetes -------------------------------------------------------------

packages <- c("tidyverse", "pROC", "forcats", "scales")

for (p in packages) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p)
    library(p, character.only = TRUE)
  }
}

# 2. Cargar datos procesados ----------------------------------------------

df_model <- read.csv("../data/processed/df_model_clean.csv", stringsAsFactors = FALSE)

pred_df <- read.csv("../data/processed/model_predictions.csv", stringsAsFactors = FALSE)

or_reduced <- read.csv("../data/processed/or_reduced.csv", stringsAsFactors = FALSE)

# 3. Tema general y colores -----------------------------------------------

col_lgg <- "#00BFC4"
col_gbm <- "#F8766D"

theme_set(
  theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5, size = 15),
      axis.title = element_text(face = "bold"),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank()
    )
)

# 4. Preparación de datos -------------------------------------------------

df_model <- df_model %>%
  mutate(
    Grade = ifelse(Grade_bin == 0, "LGG", "GBM"),
    Grade = factor(Grade, levels = c("LGG", "GBM"))
  )

gene_bin_cols <- df_model %>%
  select(ends_with("_bin")) %>%
  select(-Grade_bin) %>%
  colnames()

# 5. Figura 1: Distribución por grado tumoral -----------------------------

fig1 <- df_model %>%
  count(Grade) %>%
  ggplot(aes(x = Grade, y = n, fill = Grade)) +
  geom_col(width = 0.6, colour = "white", linewidth = 0.3) +
  scale_fill_manual(values = c("LGG" = col_lgg, "GBM" = col_gbm)) +
  labs(
    title = "Distribución por grado tumoral",
    x = "Grado tumoral",
    y = "Número de pacientes"
  ) +
  theme(legend.position = "none")

fig1

ggsave(
  "../figures/distribucion_grado_tumoral.png",
  fig1,
  width = 5,
  height = 4,
  dpi = 300
)

# 6. Figura 2: Frecuencia de mutación por gen -----------------------------

mut_rates <- colMeans(df_model[, gene_bin_cols])

mut_df <- tibble(
  gene = names(mut_rates),
  freq = as.numeric(mut_rates)
) %>%
  mutate(
    gene = gsub("_bin", "", gene),
    label = percent(freq, accuracy = 1)
  )

fig2 <- mut_df %>%
  ggplot(aes(x = reorder(gene, freq), y = freq)) +
  geom_col(fill = "#4E79A7", colour = "white", linewidth = 0.2) +
  coord_flip() +
  geom_text(aes(label = label), hjust = -0.1, size = 3) +
  scale_y_continuous(
    labels = percent_format(accuracy = 1),
    expand = expansion(mult = c(0, 0.1))
  ) +
  labs(
    title = "Frecuencia de mutación por gen",
    x = "Gen",
    y = "Frecuencia de mutación"
  )

fig2

ggsave(
  "../figures/frecuencia_mutacion_por_gen.png",
  fig2,
  width = 7,
  height = 5,
  dpi = 300
)

# 7. Figura 3: Proporción de mutación por grado ---------------------------

genes_interest <- c(
  "IDH1_bin", "IDH2_bin", "TP53_bin",
  "MUC16_bin", "NF1_bin", "PTEN_bin", "EGFR_bin"
)

df_long <- df_model %>%
  select(Grade, all_of(genes_interest)) %>%
  pivot_longer(
    cols = -Grade,
    names_to = "gene",
    values_to = "mut"
  ) %>%
  group_by(Grade, gene) %>%
  summarise(prop_mut = mean(mut), .groups = "drop") %>%
  mutate(
    gene = gsub("_bin", "", gene)
  )

fig3 <- df_long %>%
  ggplot(aes(x = Grade, y = prop_mut, fill = Grade)) +
  geom_col(width = 0.6, colour = "white", linewidth = 0.2) +
  scale_fill_manual(values = c("LGG" = col_lgg, "GBM" = col_gbm)) +
  facet_wrap(~ gene, ncol = 3) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(
    title = "Proporción de mutación por grado tumoral",
    x = "Grado tumoral",
    y = "Proporción de mutación"
  ) +
  theme(legend.position = "none")

fig3

ggsave(
  "../figures/proporcion_mutacion_por_grado.png",
  fig3,
  width = 7,
  height = 5,
  dpi = 300
)

# 8. Figura 4: Edad por grado tumoral ------------------------------------

fig4 <- df_model %>%
  filter(Age_years > 0) %>%
  ggplot(aes(x = Grade, y = Age_years, fill = Grade)) +
  geom_violin(trim = FALSE, alpha = 0.7, colour = NA) +
  geom_jitter(width = 0.1, alpha = 0.25, size = 1.5, colour = "black") +
  scale_fill_manual(values = c("LGG" = col_lgg, "GBM" = col_gbm)) +
  labs(
    title = "Edad al diagnóstico por grado tumoral",
    x = "Grado tumoral",
    y = "Edad al diagnóstico (años)"
  ) +
  theme(legend.position = "none")

fig4

ggsave(
  "../figures/edad_por_grado_tumoral.png",
  fig4,
  width = 5,
  height = 4,
  dpi = 300
)

# 9. Figura 5: Odds Ratios del modelo reducido ----------------------------

or_plot_df <- or_reduced %>%
  filter(term != "const") %>%
  mutate(
    term_label = recode(
      term,
      "Age_years" = "Edad",
      "IDH1_bin" = "IDH1",
      "IDH2_bin" = "IDH2",
      "TP53_bin" = "TP53",
      "MUC16_bin" = "MUC16",
      "NF1_bin" = "NF1",
      .default = term
    ),
    term_label = factor(
      term_label,
      levels = c("TP53", "MUC16", "Edad", "NF1", "IDH2", "IDH1")
    )
  )

fig5 <- or_plot_df %>%
  ggplot(aes(x = OR, y = term_label)) +
  geom_point(size = 2.3) +
  geom_errorbarh(
    aes(xmin = CI_low, xmax = CI_high),
    height = 0.15,
    linewidth = 0.6
  ) +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey40") +
  scale_x_log10(
    breaks = c(0.01, 0.1, 1, 10),
    labels = c("0.01", "0.1", "1", "10")
  ) +
  labs(
    title = "Modelo reducido: Odds Ratios para GBM",
    x = "Odds Ratio (escala logarítmica)",
    y = NULL
  )

fig5

ggsave(
  "../figures/odds_ratios_modelo_reducido.png",
  fig5,
  width = 6,
  height = 4,
  dpi = 300
)

# 10. Figura 6: Matriz de confusión --------------------------------------

cm <- table(
  Real = pred_df$Grade_bin,
  Predicted = pred_df$pred_red
)

cm_df <- as.data.frame(cm) %>%
  mutate(
    Real = factor(
      Real,
      levels = c(0, 1),
      labels = c("LGG real", "GBM real")
    ),
    Predicted = factor(
      Predicted,
      levels = c(0, 1),
      labels = c("LGG predicho", "GBM predicho")
    )
  )

fig6 <- ggplot(cm_df, aes(x = Predicted, y = Real, fill = Freq)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = Freq), size = 5, fontface = "bold", colour = "black") +
  scale_fill_gradient(low = "#EAF2F8", high = "#2E86C1") +
  labs(
    title = "Matriz de confusión - modelo reducido",
    x = "Predicción",
    y = "Valor real",
    fill = "Casos"
  ) +
  theme(legend.position = "right")

fig6

ggsave(
  "../figures/matriz_confusion_modelo_reducido.png",
  fig6,
  width = 5,
  height = 4,
  dpi = 300
)

# 11. Figura 7: Curva ROC -------------------------------------------------

roc_red <- pROC::roc(pred_df$Grade_bin, pred_df$prob_red)

auc_red <- pROC::auc(roc_red)

fig7 <- ggroc(roc_red, size = 1.2, colour = "#2C3E50") +
  geom_abline(
    slope = 1,
    intercept = 1,
    linetype = "dashed",
    colour = "grey60"
  ) +
  annotate(
    "text",
    x = 0.8,
    y = 0.15,
    label = paste("AUC =", round(auc_red, 2)),
    size = 4
  ) +
  labs(
    title = "Curva ROC - modelo reducido",
    x = "1 - Especificidad",
    y = "Sensibilidad"
  )

fig7

ggsave(
  "../figures/curva_roc_modelo_reducido.png",
  fig7,
  width = 5,
  height = 4,
  dpi = 300
)

############################################################
# Fin del script
############################################################

