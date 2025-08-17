---
layout: page
title: ResTIR and ResTIR PT on La Jolla renderer
description: a Computer Graphic Project
img: /assets/img/posts/restir/many_lights_restir_pt/bunny_restir_pt_spp_1_depth_1_size_32_neighbor_1.png
importance: 1
category: work
related_publications: false
---

In this project, I implemented **ReSTIR** and **ReSTIR PT** rendering algorithms from NVIDIA in the La Jolla renderer (created for teaching purposes at UCSD).  
These two algorithms significantly improve rendering performance in complex lighting conditions:

- **ReSTIR (Reservoir-based Spatiotemporal Importance Resampling)**  
  Instead of sampling lights independently for each pixel, ReSTIR maintains *reservoirs* of light samples that can be reused across both space (neighboring pixels) and time (previous frames).  
  This makes it possible to render scenes with **thousands or even millions of light sources** while still producing low-noise results in just one sample per pixel (spp).

- **ReSTIR PT (Path Tracing with ReSTIR)**  
  Extends ReSTIR beyond direct lighting. By applying the same reservoir resampling strategy to indirect lighting paths, ReSTIR PT allows more efficient global illumination.  
  This leads to **faster convergence and reduced noise** in scenes dominated by multiple light bounces, where traditional path tracing struggles.

Together, these methods make physically-based rendering feasible in real time, even for scenes with dense lighting and complex visibility.

### Example Results

<div class="row">
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/restir/path_depth_2.png" title="Path Tracer" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/restir/final/restir_neighbor_1_spp_1.png" title="ReSTIR" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/restir/many_lights_restir_pt/monkey_restir_pt_spp_1_size_32_depth_1_neighbor_1.png" title="ReSTIR PT" class="img-fluid rounded z-depth-1" %}
  </div>
</div>

<div class="row">
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/restir/bunny_restir/path_tracer_spp_1_depth_1.png" title="Path Tracer" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/restir/bunny_restir/restir_spp_1_size_32_neighbor_1.png" title="ReSTIR" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/restir/many_lights_restir_pt/bunny_restir_pt_spp_1_depth_1_size_32_neighbor_1.png" title="ReSTIR PT" class="img-fluid rounded z-depth-1" %}
  </div>
</div>

**Figure:** Image rendered from two scenes by **Path Tracer** (first column), **ReSTIR** (second column), and **ReSTIR PT** (last column).

---

### Resources
- 📂 [GitHub Repository](https://github.com/your-username/your-repo)  
- 📑 [Full Report (PDF)](https://ginlov.github.io/assets/pdf/cse272_report.pdf)

---

### References
- Bitterli, B., Speierer, S., Wrenninge, M., Shirley, P., & Keller, A. (2020).  
  *Spatiotemporal reservoir resampling for real-time ray tracing with dynamic direct lighting.*  
  ACM Transactions on Graphics (SIGGRAPH). [Paper link](https://research.nvidia.com/labs/rtr/Restir/)  

- Müller, T., Keller, A., & Wrenninge, M. (2021).  
  *ReSTIR Path Tracing.*  
  ACM Transactions on Graphics (SIGGRAPH). [Paper link](https://research.nvidia.com/publication/2021-07_ReSTIR-PT)  

- [La Jolla Renderer](https://github.com/BachiLi/lajolla_public) – teaching renderer developed at UCSD.