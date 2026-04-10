---
layout: page
title: MAE204 — Mobile Manipulation with the youBot
description: Feedforward + PI task-space control for pick-and-place on a mobile manipulator
img: assets/img/posts/mae204/project_thumb.png
importance: 4
category: work
related_publications: false
---

📄 [Full Report (PDF)](https://ginlov.github.io/assets/pdf/mae204_final_project.pdf)

This page covers the lab assignments and final project from **MAE 204: Introduction to Robotics** at UC San Diego, all using the **UR3e robot arm** and the **Modern Robotics** framework.

---

## Lab 1 — Introduction to the UR3e

First contact with the physical **UR3e** robot (6-joint tabletop arm, 11 kg, 3 kg payload, ±360° joint limits). The robot was controlled entirely via the **teach pendant** — no code, no scripting.

The task was the classic **Tower of Hanoi**: three stacked blocks on tower A must be moved to another tower, one block at a time, without placing a larger-numbered block on a smaller one. Each pick-and-place move was programmed by physically jogging the arm to each position and recording it as a waypoint (Basic > Waypoint > Set Waypoint) on the pendant. The standby configuration was fixed at joint angles `[-30, -90, 90, -90, -90, 150]` degrees.
<iframe src="https://drive.google.com/file/d/1C3I9YWUskKHZMNjPDPlMfzTCs0QJqqa5/preview" width="640" height="480"></iframe>
---

## Lab 2 — Forward Kinematics

Implemented forward kinematics for the physical UR3e robot arm using the **product of matrix exponentials**:

$$T(\theta) = e^{[S_1]\theta_1} e^{[S_2]\theta_2} \cdots e^{[S_6]\theta_6} M$$

The six screw axes $S_1 \ldots S_6$ and the zero-configuration end-effector matrix $M$ were derived by hand from physical measurements of the robot. The MATLAB script converts joint angles (degrees) to the end-effector SE(3) transformation and prints position in mm. Results were verified in the lab by commanding the real UR3e to specific joint configurations and measuring the end-effector position.

---

## Lab 3 — Inverse Kinematics

Implemented **numerical inverse kinematics** via the Newton-Raphson method with the Moore-Penrose pseudoinverse of the body Jacobian (`IKinSpace` from the Modern Robotics library), extended with joint-limit wraparound correction to keep all angles within ±360°.

The lab scenario: an **Evil Dragon** is invading UCSD and threatening the coffee supply. The only defense is to assemble the **Effigy of Graduate Student-Warrior** — three scattered blocks (legs, body, head) — using the UR3e with a Robotiq Hand-E gripper. The IK script computed a 15-waypoint sequence of SE(3) gripper poses, solved for joint angles at each waypoint, and output a `waypoint_array.csv` that drove the real robot to pick and stack the blocks in order.

<iframe src="https://drive.google.com/file/d/1Vv6N65hjA5Btc90yiUhMzIchy-cSqL5E/preview" width="640" height="480"></iframe>

---

## Final Project — Mobile Manipulation with the youBot

This project implements a complete software stack to control a **youBot mobile manipulator** performing a pick-and-place task in CoppeliaSim Scene 6: driving to a cube, grasping it, and placing it at a target location.

---

## System Architecture

The pipeline is organized into four components:

1. **NextState** — A first-order Euler simulator propagating the 12-variable robot configuration (chassis pose + 5 arm joints + 4 wheel angles) given commanded velocities. Chassis odometry uses the exact body-twist integration from Modern Robotics Ch. 13.4; joint/wheel speeds are clipped to a configurable maximum.

2. **TrajectoryGenerator** — Produces an 8-segment reference trajectory for the end-effector using `ScrewTrajectory` from the Modern Robotics library:
   - Move to standoff above cube → Descend to grasp → Close gripper → Lift to standoff
   - Move to goal standoff → Descend to place → Open gripper → Return to standoff

3. **FeedbackControl** — Implements the feedforward + PI control law (MR Eq. 11.16 / 13.37):

$$\mathcal{V}(t) = [\text{Ad}_{X^{-1}X_d}]\,\mathcal{V}_d + K_p\, X_{\text{err}} + K_i \int_0^t X_{\text{err}}\,dt$$

   where $X_{\text{err}} = \log(X^{-1}X_d)$. The commanded twist $\mathcal{V}$ is mapped to wheel and arm joint speeds via the pseudoinverse of the $6\times9$ mobile-manipulator Jacobian $J_e(\theta)$.

4. **Run script** — Ties all components together, outputs a CSV file playable in CoppeliaSim.

---

## Engineering Decisions

**Singularity avoidance.** The end-effector approaches at a 45° angle from vertical rather than horizontally. A horizontal approach placed the arm near full extension at the grasp pose, producing a near-singular Jacobian and unreasonably large joint speeds. The 45° tilt keeps the arm well-conditioned. Pseudoinverse tolerance is set to `rcond=1e-3` to suppress near-zero singular values.

**Self-collision avoidance.** Certain cube goal orientations caused the arm to fold backward over the chassis. Inspecting offending CSV files revealed joints well outside physical limits (e.g., θ₄ = −3.8 rad vs. limit ±1.79 rad). The Jacobian-column-zeroing method from MR Capstone was evaluated but degraded tracking enough to cause grasp failures. The adopted solution: careful task-geometry selection combined with the pseudoinverse tolerance to keep the arm in its forward workspace.

---

## Results

### Best Case — Feedforward + P Control

**Gains:** $K_p = 3I$, $K_i = 0$  
**Initial config:** $(\phi, x, y) = (\pi/6, -0.3, 0.1)$, 40.1° orientation error, 0.337 m position error  

<iframe src="https://drive.google.com/file/d/1k47eDMrNscEjEdjeGIvS8-kIxcNGAcTa/preview" width="640" height="480"></iframe>

All six error components converge smoothly and monotonically to zero within ~2 seconds, with no overshoot. The error constant of ~0.33 s ensures full convergence well before the grasp at t ≈ 5 s.

<div class="row">
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/mae204/best_xerr.png" title="Best case — end-effector error" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/mae204/best_manipulability.png" title="Best case — manipulability" class="img-fluid rounded z-depth-1" %}
  </div>
</div>
<div class="caption">
  Best case: end-effector error X_err (left) and manipulability μ₁(Aω), μ₁(Av) (right) vs. simulation time. Smooth convergence with no overshoot.
</div>

---

### Overshoot Case — Feedforward + PI Control

**Gains:** $K_p = 2I$, $K_i = 8I$  

<iframe src="https://drive.google.com/file/d/1_8JGWFlGPngO6y5c300GVWcplu7xEDj8/preview" width="640" height="480"></iframe>

The aggressive integral gain causes clear overshoot and oscillation in ωₓ, ωᵧ, and vᵧ components. The integrator accumulates past error and overshoots zero, producing an underdamped transient that settles by t ≈ 4 s — still in time for a successful grasp.

<div class="row">
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/mae204/overshoot_xerr.png" title="Overshoot case — end-effector error" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/mae204/overshoot_manipulability.png" title="Overshoot case — manipulability" class="img-fluid rounded z-depth-1" %}
  </div>
</div>
<div class="caption">
  Overshoot case: oscillatory transient from the aggressive integral term (K_i = 8I). Error settles before the grasp phase.
</div>

---

### New Task — Custom Workspace Configuration

**Gains:** $K_p = 5I$, $K_i = 1I$  
**Initial config:** $(\phi, x, y) = (0.3, -0.3, -0.3)$, 31.9° orientation error, 0.240 m position error  
**Cube:** initial $(0.5, -0.6, 0)$ → goal $(1.0, 0.5, -\pi/4)$  
**Video:** *(coming soon)*

<iframe src="https://drive.google.com/file/d/1m_9C1iwSUSgHzJZKXICQTSl9H1gdUBYX/preview" width="640" height="480"></iframe>

The cube is picked up from the right side of the workspace and placed at a −45° rotation in the forward-left area. Configuration is loaded from an external YAML file (`newtask_config.yaml`). All six error components decay monotonically — smooth convergence with no overshoot.

<div class="row">
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/mae204/newtask_xerr.png" title="New task — end-effector error" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/mae204/newtask_manipulability.png" title="New task — manipulability" class="img-fluid rounded z-depth-1" %}
  </div>
</div>
<div class="caption">
  New task: pick-and-place with a custom cube placement geometry. Monotonic convergence with well-tuned PI gains.
</div>

---

## Key Takeaways

- **Integral term trade-off:** Eliminates steady-state error from modeling biases but causes overshoot as the accumulated integral drives the system past the reference. Higher K_i worsens oscillation.
- **Manipulability:** μ₁(Av) drops near 0.1 during grasp/place approach (arm near full extension → near-singular Jacobian), then recovers during transport. μ₁(Aω) stays near 0.31 during steady-state motion.
- **Velocity vs. torque control:** Velocity control is adequate for free-space pick-and-place but insufficient for contact-rich tasks (surface polishing, peg-in-hole) where force/torque feedback and the full dynamic model (mass matrix, Coriolis terms) are required.
