# Species Distribution Satellite Models

Predicting tree species presence across Himachal Pradesh (India) using Sentinel-1 SAR and Sentinel-2 optical imagery. This repository contains data-prep pipelines, feature engineering notebooks, and modelling code for Random Forest, XGBoost, and experimental deep-learning workflows used in an ongoing research project.

**Highlights:**
- Multi-source raster preprocessing (Sentinel-1 SAR, Sentinel-2 MSI)
- Feature engineering and point-to-raster extraction pipelines
- Modeling recipes in R (RF, XGBoost, GLM) and Python (RF wrapper + DL notebooks)

**Data sources:**
- Sentinel-1 (VV, VH) — C-band SAR derived products (10 m)
- Sentinel-2 (B2, B3, B4, B8) — Level-2A surface reflectance (10 m)
- Point presence-only tree species datasets (project-internal)

Monthly medians for 2018–2024 were used to build spatial feature stacks; rasters were prepared using a mix of Python, R, and QGIS utilities.

**Note:** This repository contains scripts and analysis notebooks; it does not include raw satellite data or proprietary presence records. Before making the project public, verify that any data you upload is allowed for public release.

**Repository structure**
- [src](src): source code and notebooks
    - [src/geospatial_pipeline](src/geospatial_pipeline): download / query helper scripts for Sentinel products (`get_s1_q.py`, `get_s2_q.py`)
    - [src/make_pred_tiff](src/make_pred_tiff): raster reprojection / tiling / masking utilities and R helpers for making prediction bricks
    - [src/py_pipeline](src/py_pipeline): Python notebooks and `compile_data.py` for assembling feature tables and covariates
    - [src/rf_codes](src/rf_codes): Random Forest training and prediction scripts (R and Python wrappers)
    - [src/xgb](src/xgb): XGBoost experiments and R run scripts
    - [src/glm_codes](src/glm_codes): GLM-based robustness checks (`glm_codes.R`)
    - [src/dl_pipeline](src/dl_pipeline): deep learning notebooks and utilities (`dnn.ipynb`, `dnn_lin.ipynb`)

**Key files**
- [src/py_pipeline/compile_data.py](src/py_pipeline/compile_data.py): assemble species point data and covariates into modelling tables
- [src/rf_codes/rf_all_species_train.py](src/rf_codes/rf_all_species_train.py): training wrapper for multi-species RF models
- [src/dl_pipeline/dnn_lin.ipynb](src/dl_pipeline/dnn_lin.ipynb): linear neural network notebook used for DL experiments

**Getting started (quick)**
1. Create a Python environment and install common dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install numpy pandas rasterio rioxarray geopandas scikit-learn xgboost jupyterlab
```

2. Install common R packages used by scripts (run in R):

```r
install.packages(c('raster','rgdal','sf','caret','randomForest','xgboost'))
```

3. Prepare rasters: use scripts in [src/make_pred_tiff](src/make_pred_tiff) to reproject, tile, and compute monthly medians. Use [src/geospatial_pipeline/get_s1_q.py](src/geospatial_pipeline/get_s1_q.py) and [src/geospatial_pipeline/get_s2_q.py](src/geospatial_pipeline/get_s2_q.py) to automate downloads/queries where applicable.

4. Create modelling tables: run [src/py_pipeline/compile_data.py](src/py_pipeline/compile_data.py) (or notebook variants in `src/py_pipeline`) to extract point values and assemble covariates for training.

5. Train models: use scripts in [src/rf_codes](src/rf_codes) for Random Forest workflows, and [src/xgb](src/xgb) for XGBoost experiments. Deep-learning experiments live in [src/dl_pipeline](src/dl_pipeline).

**Recommended workflow**
- Prepare and QC rasters → assemble covariates → split/train models (RF / XGB) → evaluate and produce prediction bricks → visualize and validate.

---