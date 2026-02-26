---
layout: page
title: CVRunner - A Runner for CV Models
description: a Deep Learning Infrastructure Project
img: /assets/img/posts/cvrunner/cvrunner.png
importance: 1
category: work
related_publications: false
---

In this project, I built **CVRunner**, a Python framework that simplifies and automates the setup for deep learning model training, making it easier to manage experiments, logging, and distributed training.

CVRunner is designed to streamline the process of training deep learning models by providing:

- **Automated Logging with Weights & Biases (wandb)**
  Seamless experiment tracking and visualization without manual setup, allowing researchers to focus on model development rather than logging infrastructure.

- **Multi-GPU and Distributed Training via `DistributedTrainRunner`**
  Built-in support for distributed data parallelism, enabling efficient scaling of training workloads across multiple GPUs with minimal code changes.

- **Flexible Configuration using a Python-based `Experiment` Class**
  Define all experiment parameters—epochs, batch size, model architecture, dataset, and more—in a stateless, declarative `Experiment` class. This makes experiments fully reproducible and easy to version-control.

- **Multi-Environment Support**
  Run experiments locally, in Docker containers, or on Kubernetes clusters with minimal configuration changes, ensuring seamless transitions between development and production environments.

### Customizable Training Logic

The `Runner` class manages the state of a training job (model, optimizer, metrics, etc.) and holds a reference to the experiment configuration. To customize training, subclass the runner and override methods such as `run`, `train_epoch`, `val_epoch`, and `checkpoint`.

### Usage Examples

**Running an experiment locally:**
```bash
cvrunner -e tests/test_runner.py -l
```

**Running in a Docker container:**
```bash
cvrunner -e test/test_generator/mnist_components.py --target_image test_cvrunner --build
```

**Running on Kubernetes:**
```bash
cvrunner -e test/test_generator/mnist_components.py --target_image test_cvrunner --build --k8s
```

---

### Resources
- 📂 [GitHub Repository](https://github.com/ginlov/cvrunner)
- 📖 [Documentation](https://ginlov.github.io/cvrunner)

