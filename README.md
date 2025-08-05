# OLSFM Image Processing Code

This repository provides the image processing scripts used in the study:

**"Oblique Light Sheet Fluorescence Microscopy with Surface Tracking for High-speed Large-area Imaging of Conjunctival Goblet Cells"**

These scripts were used for surface image construction, PSF measurement, deconvolution, and evaluation of CGC segmentation accuracy.

---

## Contents

| File Name                           | Description |
|------------------------------------|-------------|
| `OLSFM_image_construction.m`       | Constructs en-face surface images from images using surface tracking data |
| `OLSFM_psf_measurement_FWHM.m`     | Measures the point spread function (PSF) and calculates FWHM from fluorescent microsphere image  |
| `OLSFM_deconvolution.m`            | Performs blind and regular deconvolution on CGC images |
| `OLSFM_cell_count.m`               | Performs automated CGC segmentation using Weka-classified data and morphological postprocessing |
| `OLSFM_comparison_automatic_manual.m` | Compares automatic and manual CGC counts using centroid matching and computes precision, recall, and accuracy |

---

## Requirements

- MATLAB R2022b or later
- Image Processing Toolbox
- MATLAB Statistics and Machine Learning Toolbox (for classification)
- Weka (optional, for retraining the segmentation model)

---
