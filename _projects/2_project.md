---
layout: page
title: DS190-Improving Ego Vehicle Performance with GRPO
description: an Autonomous Driving Project
img: /assets/img/posts/wayformer_grpo/safety_imitation_tradeoff.png
importance: 1
category: work
related_publications: false
---

In this project, I addressed the limitations of standard Imitation Learning in autonomous driving by applying **Group Relative Policy Optimization (GRPO)** to the Wayformer architecture. 
While data-driven planners excel at mimicking human behavior, they often struggle with "long-tail" scenarios—rare, high-stakes events—and fail to strictly enforce safety constraints like collision avoidance.

This project bridges that gap by integrating realistic imitation priors with rigorous reinforcement learning safety checks:

- **Wayformer with Temporal Gaussian Decoder** I utilized the Wayformer architecture to encode heterogeneous scene contexts (road graph, traffic lights, agent interactions). To improve temporal coherence, I replaced the standard linear regression head with a **Temporal Gaussian Decoder (TGD)**. This explicitly models dependencies between future time steps, ensuring generated trajectories are dynamically realistic.

- **Group Relative Policy Optimization (GRPO)** Standard RL often requires computationally expensive Critic networks. I adapted GRPO, a critic-free algorithm, to fine-tune the model's decision-making. By sampling a group of trajectory proposals and evaluating them against a hard-constraint reward function (penalizing collisions), GRPO optimizes the model to prioritize safety even when expert demonstrations are ambiguous or risky.

This approach successfully sharpens decision confidence and reduces collision rates in complex scenarios where pure imitation learning fails.

### Example Results

<div class="row">
  <div class="col-12 mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/wayformer_grpo/ambiguity_baseline.png" title="Baseline Ambiguity" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-12 mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/wayformer_grpo/confidence_grpo.png" title="GRPO Confidence" class="img-fluid rounded z-depth-1" %}
  </div>
</div>
<div class="caption">
    <strong>Decision Sharpening:</strong> The baseline model (top) exhibits high uncertainty, splitting probability across conflicting maneuvers. The GRPO-tuned model (bottom) produces a "peaked" distribution, confidently selecting the optimal path.
</div>

<div class="row">
  <div class="col-12 mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/wayformer_grpo/safety_fail_baseline.png" title="Baseline Safety Failure" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-12 mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/wayformer_grpo/safety_success_grpo.png" title="GRPO Safety Success" class="img-fluid rounded z-depth-1" %}
  </div>
</div>
<div class="caption">
    <strong>Safety vs. Imitation:</strong> In this scenario, the baseline (top) mimics an expert path that dangerously heads toward a neighbor. GRPO (bottom) suppresses this dangerous mode, deviating from the imitation target to enforce a hard safety constraint.
</div>

---

### Resources
- 📂 [GitHub Repository](https://github.com/ginlov/wayformer)
- 📑 [Full Report (PDF)](/assets/pdf/DS190_Improve_ego_vehile_performance.pdf)

---

### References
- Nayakanti, N., et al. (2023).  
  *Wayformer: Motion forecasting via simple efficient attention networks.* IEEE International Conference on Robotics and Automation (ICRA).

- Shao, Z., et al. (2024).  
  *DeepSeekMath: Pushing the limits of mathematical reasoning in open language models.* arXiv preprint arXiv:2402.03300.

- Ettinger, S., et al. (2021).  
  *Large scale interactive motion forecasting for autonomous driving: The Waymo Open Motion Dataset.* IEEE/CVF International Conference on Computer Vision (ICCV).
