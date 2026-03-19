# 🧠 Behavioral Rate-Limiter (Beyond Hard Thresholds)

## 🚀 Overview
Traditional rate limiters block users after a fixed number of requests (**N requests per minute/hour**). While effective against obvious abuse, they fail to detect **“low-and-slow” bots** that mimic human-like request rates but behave unnaturally.

The **Behavioral Rate-Limiter** uses **Machine Learning** to analyze *user behavior patterns* instead of just request counts.

---

## 🎯 Key Idea
Instead of asking:
> "How many requests did the user make?"

We ask:
> "Does this user behave like a human?"

---

## ⚙️ Features
- Detects **low-rate bots**
- Uses **behavioral analysis**
- Reduces need for CAPTCHAs
- Works as **API middleware**
- Scalable as a **microservice (Go/Rust)**

---

## 🧩 Core Concepts

### 1. Inter-arrival Time
Time between consecutive requests.
```bash
Human: 1.2s, 5.6s, 0.8s, 10s
Bot: 2s, 2s, 2s, 2s
```


### 2. Path Entropy
Measures randomness in navigation.
```bash
Human: /home → /products → /cart → /profile
Bot: /api/data → /api/data → /api/data
```

---

### 3. Feature Vector
Each session is converted into:
```bash
[avg_time, variance, entropy, request_count, unique_paths]
```

---

## 🤖 Machine Learning Models

### K-Nearest Neighbors (KNN)
- Simple classification
- Needs labeled data

### Isolation Forest (Recommended)
- Detects anomalies
- Works without labeled data

---

## 🏗️ Architecture

<p align="center">
  <img src="arch.svg" width="700"/>
</p>

---

## 🔧 Tech Stack

- Python (ML prototype)
- Go / Rust (production)
- scikit-learn
- numpy, pandas
- Docker (optional)

---

## 📦 Installation

```bash
git clone https://github.com/your-username/behavioral-rate-limiter.git
cd behavioral-rate-limiter
pip install -r requirements.txt
