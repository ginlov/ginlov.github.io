---
layout: page
title: MAE148-Autonomous Car Project
description: an Autonomous Driving Project
img: /assets/img/posts/mae148/car.png
importance: 1
category: work
related_publications: false
---

In this project, my teammates and I built an autonomous car from scratch. Below is a diagram illustrating the car's construction and appearance:

<div class="row">
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/mae148/wiring.png" title="Wiring diagram" class="img-fluid rounded z-depth-1" %}
  </div>
  <div class="col-sm mt-3 mt-md-0">
    {% include figure.liquid loading="eager" path="assets/img/posts/mae148/car.jpg" title="Car appearance" class="img-fluid rounded z-depth-1" %}
  </div>
</div>


Through this project, we trained the car to accomplish several tasks, including:
* Completing autonomous laps using the DonkeyCar KerasCNN model (input: RGB images; output: throttle and steering angle)
<iframe src="https://drive.google.com/file/d/1hDy4TEc8qSoQx4P3KFZX8Clwegyk_XBh/preview" width="640" height="480"></iframe>

* Completing autonomous laps using GPS
<iframe src="https://drive.google.com/file/d/1-dEs_OaIhxv9ICAB5_habyjwmPDTV7IO/preview" width="480" height="640"></iframe>

* Performing autonomous lane-following laps using OpenCV (cv2)
<iframe src="https://drive.google.com/file/d/1uIKhLuATGRPnQqDkwNqYKC8HqmxaE0cJ/preview" width="480" height="640"></iframe>

**Final proposed task**: automatically detecting and reaching a broken-down car

* Setup: We used a surveillance camera to monitor the road. The car was equipped with both lidar and a camera. When the surveillance camera detected a blinking hazard light, it signaled the car to search for the broken-down vehicle and park behind it to provide assistance.

* Solutions:
  * The surveillance camera used a blinking light detection model developed with OpenCV (cv2). When a hazard light was detected, a signal was sent to the car via a ROS2 topic.
  * The car used an object detection model served through Roboflow to identify the broken-down car and employed a PID control algorithm to approach it.
  * Lidar was used to determine the distance to the target. A basic sensor fusion technique was implemented to accurately map the object detected by the camera to the lidar output.

Final project demo video:
<iframe src="https://drive.google.com/file/d/1WAWvJkoGAePvwKRrCThELt2v1QTjQQPU/preview" width="480" height="640"></iframe>

---

### Resources
- 📂 [GitHub Repository](https://github.com/UCSD-ECEMAE-148/fall-2025-final-project-team-7)
- 📑 [Final Project Report](https://ginlov.github.io/assets/pdf/mae148_report.pdf)

---

### References
- [MAE 148 course](https://ucsd-ecemae-148.github.io) - Introduction to Autonomous Vehicle course.

- [DonkeyCar](https://docs.donkeycar.com) - An open source Self Driving Car Platform.

- [Roboflow](https://roboflow.com) - A platform to build and deploy computer vision applications.
