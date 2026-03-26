# Kaplan-Meier survival analysis with confidence interval

# Packages
library(survival)
library(survminer)
library(dplyr)
library(readxl)
library(ggplot2)
library(ggpubr)

# Load data
input_file <- "data/example_survival_data.xlsx"
input_sheet <- "survival_data"

data_wide <- read_excel(input_file, sheet = input_sheet)

# Clean column names
colnames(data_wide) <- trimws(colnames(data_wide))

# Check
print(colnames(data_wide))


# Clean data
data_clean <- data_wide %>%
  filter(
    !is.na(subject_id),
    !is.na(group),
    !is.na(time_days)
  ) %>%
  arrange(subject_id, time_days)

# Create Kaplan-Meier dataset
km_data <- data_clean %>%
  group_by(subject_id, group) %>%
  filter(!is.na(event)) %>%
  slice_tail(n = 1) %>%
  ungroup() %>%
  transmute(
    subject_id = subject_id,
    group = group,
    time_days = as.numeric(time_days),
    event = as.numeric(event)
  )

# Checks
print(km_data)
print(table(km_data$event, useNA = "ifany"))
print(km_data %>% arrange(group, time_days))

# Kaplan-Meier fit
km_fit <- survfit(Surv(time_days, event) ~ group, data = km_data)

# p-value
p_value <- surv_pvalue(km_fit, data = km_data)
print(p_value)

# Define x-axis breaks
max_time <- ceiling(max(km_data$time_days, na.rm = TRUE))
x_breaks <- pretty(c(0, max_time), n = 5)

# Kaplan-Meier plot
km_plot_obj <- ggsurvplot(
  km_fit,
  data = km_data,
  conf.int = TRUE,
  pval = FALSE,
  risk.table = FALSE,
  xlab = "Time",
  ylab = "Survival probability",
  title = "Kaplan-Meier survival analysis",
  palette = c("black", "red"),
  legend.title = "Group",
  surv.median.line = "hv",
  censor = TRUE,
  censor.shape = 3,
  censor.size = 4
)

main_plot <- km_plot_obj$plot +
  scale_x_continuous(breaks = x_breaks) +
  annotate(
    "text",
    x = x_breaks[2],
    y = 0.2,
    label = p_value$pval.txt,
    size = 5
  ) +
  theme_classic() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 13),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    legend.position = "top"
  )

# Number-at-risk table data
risk_summary <- summary(km_fit, times = x_breaks, extend = TRUE)

risk_table <- data.frame(
  time = risk_summary$time,
  strata = risk_summary$strata,
  n_risk = risk_summary$n.risk
)

risk_table <- risk_table %>%
  mutate(
    strata = gsub("^group=", "", strata)
  )

print(risk_table)

# Number-at-risk plot
risk_table_plot <- ggplot(
  risk_table,
  aes(x = time, y = strata, label = n_risk, color = strata)
) +
  geom_text(size = 5) +
  scale_x_continuous(breaks = x_breaks) +
  scale_color_manual(values = c("black", "red")) +
  labs(
    title = "Number at risk",
    x = "Time",
    y = "Group"
  ) +
  theme_classic() +
  theme(
    legend.position = "none",
    plot.title = element_text(hjust = 0, face = "bold"),
    axis.text.y = element_text(size = 12),
    axis.text.x = element_text(size = 12),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12)
  )

# Combine plots
final_plot <- ggarrange(
  main_plot,
  risk_table_plot,
  ncol = 1,
  nrow = 2,
  heights = c(3, 1.2),
  align = "v"
)

print(final_plot)