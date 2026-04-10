---
layout: page
title: ECE276A — Sensing & Estimation in Robotics
description: a Robotics project
img: assets/img/posts/ece276a/p2_optimised_maps_ds20.png
importance: 3
category: work
related_publications: false
---

A series of three projects from **ECE 276A: Sensing & Estimation in Robotics** at UC San Diego, building up from IMU-only state estimation to a full visual-inertial SLAM system.

---

## Project 1 — Orientation Tracking

📄 [Full Report (PDF)](https://ginlov.github.io/assets/pdf/ece276a_p1_orientation_tracking.pdf)

IMU-based 3D orientation estimation formulated as a **batch optimization problem on the quaternion manifold**, followed by panoramic image generation from a monocular camera.

**Pipeline:**
1. **IMU Calibration** — Gyroscope and accelerometer biases are estimated from a static interval (detected via VICON ground truth) and aggregated across all datasets for robustness.
2. **Orientation Prediction** — The bias-corrected gyroscope is integrated via discrete-time quaternion kinematics:

$$\mathbf{q}_{t+1} = \mathbf{q}_t \circ \exp\!\left([0,\; \tfrac{\tau_t \boldsymbol{\omega}_t}{2}]\right)$$

3. **Batch Optimization** — A cost function combining a motion-consistency term (quaternion log residual) and an accelerometer gravity-alignment observation term is minimized with **projected gradient descent** using PyTorch autograd. After each gradient step, quaternions are projected back onto the unit-norm constraint.
4. **Panorama Generation** — Each camera frame is associated with the nearest IMU orientation by timestamp, pixels are mapped to direction vectors via a spherical projection model, and accumulated onto a global panorama canvas.

**Key result:** Optimization substantially reduces roll and pitch error. Yaw remains unobservable from accelerometer measurements alone (gravity provides no constraint about the vertical axis), which is reflected in residual panorama misalignment.

<div class="row">
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/ece276a/p1_rpy_error_predicted.png" title="RPY error — gyroscope integration only" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/ece276a/p1_rpy_error_optimized.png" title="RPY error — after batch optimization" class="img-fluid rounded z-depth-1" %}
  </div>
</div>
<div class="caption">
  Roll-pitch-yaw absolute error distribution before (left) and after (right) batch optimization. Roll and pitch improve significantly; yaw is unobservable from gravity alone.
</div>

<div class="row">
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/ece276a/p1_panorama.png" title="Panorama — optimized orientation" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/ece276a/p1_panorama_vicon.png" title="Panorama — VICON ground truth" class="img-fluid rounded z-depth-1" %}
  </div>
</div>
<div class="caption">
  Panoramas constructed from optimized IMU orientations (left) vs. VICON ground truth (right).
</div>

---

## Project 2 — LiDAR-Based SLAM

📄 [Full Report (PDF)](https://ginlov.github.io/assets/pdf/ece276a_p2_lidar_slam.pdf)

A full 2D SLAM pipeline for a differential-drive robot equipped with wheel encoders, an IMU, a Hokuyo LiDAR, and a Kinect RGBD camera.

**Pipeline:**
1. **Encoder + IMU Odometry** — Wheel encoder counts are converted to per-side displacements; IMU yaw rate is interpolated onto encoder timestamps. A midpoint integration scheme propagates the SE(2) pose.
2. **ICP Scan Matching** — Consecutive LiDAR frames are aligned using the **Kabsch (SVD) algorithm** initialized from odometry. Two complementary outlier rejection mechanisms are introduced:
   - **Trimmed ICP** — retains only the closest *p*% of correspondences per iteration.
   - **Max-distance guard** — unconditionally rejects pairs beyond a hard distance threshold before the percentile trim.
3. **Occupancy Grid Mapping** — A 0.05 m/cell log-odds grid is updated using Bresenham ray tracing for each LiDAR scan.
4. **Floor Texture Mapping** — Kinect depth frames are converted to 3D points, projected to world frame via a rigid transform chain, and floor points (|z| < 0.2 m) are averaged into a color grid.
5. **Pose Graph Optimization (GTSAM)** — A factor graph is built with odometry factors and loop closure factors (fixed-interval + proximity-based). All loop closure edges use a **Huber robust kernel**. The graph is optimized with Levenberg–Marquardt.

**Key result:** The combined Trim 90 + MaxDist 1.0 m ICP configuration achieves **+29% accepted loop closures** on Dataset 20 and **+27%** on Dataset 21 compared to classic ICP. Pose graph optimization achieves a **76% / 72% error reduction** on the two datasets, producing sharp occupancy maps with correct room and corridor closure.

<div class="row">
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/ece276a/p2_trajectory_comparison.png" title="Trajectory: scan-matched vs. GTSAM-optimized" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/ece276a/p2_occupancy_comparison.png" title="Occupancy map before and after optimization" class="img-fluid rounded z-depth-1" %}
  </div>
</div>
<div class="caption">
  Left: scan-matched (blue) vs. GTSAM-optimized (red) trajectories with loop closure edges (green). Right: occupancy maps before and after pose graph optimization — sharper walls and closed corridors after optimization.
</div>

<div class="row justify-content-center">
  <div class="col-sm-8 mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/ece276a/p2_optimised_maps_ds20.png" title="Final occupancy and texture maps" class="img-fluid rounded z-depth-1" %}
  </div>
</div>
<div class="caption">
  Final occupancy map (left) and floor texture map from Kinect RGBD (right), both built from GTSAM-optimized trajectories.
</div>

---

## Project 3 — Visual-Inertial SLAM

📄 [Full Report (PDF)](https://ginlov.github.io/assets/pdf/ece276a_p3_visual_inertial_slam.pdf)

An incremental **EKF-based visual-inertial SLAM** pipeline fusing IMU body-frame velocities with stereo camera feature observations. Implemented in four progressive stages.

**Pipeline:**
1. **Task 1 — IMU EKF Prediction** — SE(3) poses are propagated via the matrix exponential on se(3). The 6×6 covariance is tracked using the adjoint-based state transition matrix.
2. **Task 2 — Feature Tracking (extra credit)** — For dataset 02 (raw stereo images), a custom tracker uses Shi-Tomasi corner detection with grid-based balancing, Lucas-Kanade pyramidal optical flow with forward-backward consistency, and epipolar-constrained stereo matching. A critical fix: replacing a slot-pool ID scheme with a **monotonic counter** prevented different physical landmarks from sharing the same tensor column, which had been causing EKF divergence.
3. **Task 3 — Landmark Mapping** — Each 3D landmark is maintained with an independent 3×3 covariance. A key improvement was adding **landmark process noise** (Q_lm = 0.01·I₃) to prevent covariance collapse — without it, Kalman gains shrank to near-zero and the filter effectively stopped updating. Successful EKF updates increased from ~5,000 to ~65,000–155,000.
4. **Task 4 — Visual-Inertial SLAM** — Per timestep: (a) IMU prediction, (b) batch **pose update in information form** using well-converged landmarks (≥6 observations, trace(P) < 15), (c) landmark initialization and EKF update using the corrected pose. Conservative tuning (high pose noise σ = 25 px, innovation filter at 15 px, hard correction cap ‖δξ‖ ≤ 0.15) prevents overcorrection while still providing meaningful drift reduction.

**Key insight:** Phase reordering — performing the pose correction *before* landmark updates — significantly improved landmark accuracy because stereo triangulation is highly sensitive to pose errors.

<div class="row">
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/ece276a/p3_imu_trajectory.png" title="IMU-only trajectory (drifts over time)" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/ece276a/p3_landmark_map.png" title="Landmark map with fixed IMU poses" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/ece276a/p3_slam_map.png" title="Visual-inertial SLAM result" class="img-fluid rounded z-depth-1" %}
  </div>
</div>
<div class="caption">
  Left: IMU-only trajectory (open-loop drift). Center: landmark map with poses fixed at IMU predictions. Right: full visual-inertial SLAM — blue is IMU prediction, green is SLAM-corrected trajectory, black dots are the landmark map.
</div>
