# Genomic Prediction of Glioma Tumor Grade

This project explores the relationship between genomic mutations and glioma tumor grade using logistic regression models.  
The analysis focuses on distinguishing between lower-grade gliomas (LGG) and glioblastomas (GBM) using selected genetic alterations and clinical variables.

The project combines data preprocessing, exploratory analysis, statistical modelling and visualization in order to identify genomic patterns associated with tumor aggressiveness.

---

## Project overview

Gliomas are among the most common primary brain tumors and show strong molecular heterogeneity.  
Certain mutations, such as alterations in IDH1 or TP53, are known to be associated with different tumor behaviors and prognostic profiles.

In this project:

- Genomic mutation data were processed and cleaned
- Mutation variables were transformed into binary predictors
- Logistic regression models were developed to classify tumor grade
- Model performance was evaluated using ROC curves, AUC and confusion matrices
- A reduced predictive model was also generated using selected variables

---

## Repository structure

```text
data/
├── raw/           # Original datasets
├── processed/     # Cleaned and processed datasets

figures/            # Generated figures and plots

notebooks/          # Jupyter notebooks used during the analysis

poster/             # Final poster in PDF format

scripts/            # R scripts for figure generation
```

---

## Dataset

The dataset used in this project was obtained from the UCI Machine Learning Repository:

> UCI Machine Learning Repository. (n.d.). *Glioma Grading Clinical and Mutation Features Dataset*.  
> https://archive.ics.uci.edu/dataset/759/glioma+grading+clinical+and+mutation+features+dataset

The dataset contains clinical and genomic information from glioma patients, including:

- Tumor grade (LGG / GBM)
- Age at diagnosis
- Mutation status of multiple genes:
  - IDH1
  - IDH2
  - TP53
  - ATRX
  - EGFR
  - PTEN
  - NF1
  - MUC16
  - among others

Mutation states were converted into binary variables (`MUTATED` = 1, `NOT_MUTATED` = 0) for modelling purposes.

---

## Analysis workflow

### 1. Data preprocessing

- Dataset loading and inspection
- Age conversion into numerical values
- Mutation binarization
- Missing value filtering

### 2. Exploratory analysis

Several visualizations were generated to explore:

- Tumor grade distribution
- Mutation frequencies
- Mutation patterns across grades
- Age distribution by tumor type

### 3. Logistic regression modelling

A logistic regression classifier was trained using genomic and clinical predictors.

Model evaluation included:

- Accuracy
- Confusion matrix
- Sensitivity and specificity
- ROC curve and AUC

### 4. Reduced predictive model

A simplified model using selected predictors was also evaluated in order to improve interpretability while maintaining predictive performance.

---

## Main findings

Some relevant observations obtained during the analysis include:

- IDH1 and IDH2 mutations were strongly associated with LGG tumors
- TP53 and MUC16 mutations showed stronger association with GBM
- Age at diagnosis contributed to the predictive capacity of the model
- The reduced model achieved an AUC close to 0.90

These results are consistent with previously described molecular patterns in glioma classification.

---

## Technologies used

- Python
- R
- pandas
- NumPy
- scikit-learn
- statsmodels
- ggplot2
- matplotlib
- seaborn

---

## Author

Juan Carlos Correro Malia

Project developed for the subject *Ciencia de Datos* in the Biomedicine degree.
