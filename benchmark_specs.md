# Benchmark Specifications & Reproducibility Protocol

## 1. Overview
This specification document formalizes the reproducibility parameters for:
**"A Lightweight Trust Management Framework for Mitigating Sybil Attacks in Edge-Assisted Internet of Things (IoT)"**  
*Authors:* Ibrahim Tanko & Nana Kofi Ahoi Appiah-Badu (Christian Service University, Kumasi, Ghana).

---

## 2. Benchmark Source & Versions
1. **LTMF (Proposed)**: Authors' implementation in Python 3.11 with NetworkX 3.2.1, NumPy 1.26.4, SciPy 1.12.0, scikit-learn 1.4.1.
2. **BTEM**: Behavioral Trust Evaluation Model based on Bao & Chen (2012) [8] and Chen et al. (2015) [6] (IEEE TDSC 13(6)). Adapted for edge cluster supervisors with sliding window buffer.
3. **DTrust**: Dirichlet-based Distributed Trust Management based on Fung et al. (2011) [23] (IEEE TNSM 8(2)) and Mendoza & Kleinschmidt (2015) [14] (IJDSN 11(11)). Adapted with 3-class multinomial evidence vector and time-forgetting decay.
4. **SybilEdge**: Graph-ML assisted Sybil detection adapted from Singh et al. (2021) [25] (IEEE IoTJ 9(1)) and SybilGuard / SybilLimit [5, 21]. Uses 2-hop topological metrics and random forest inference.

---

## 3. Mathematical Formulations & Parameters

### 3.1 Direct Trust (T_D)
$$T_D(d_i, t) = \frac{\sum_v [\lambda(t - t_v) \cdot o_v]}{\sum_v \lambda(t - t_v)}$$
- Decay parameter: $\lambda = 0.85$
- Observation window: $W = 50$ discrete events ($o_v \in \{0, 1\}$)

### 3.2 Indirect Trust (T_I)
$$T_I(d_i, t) = \frac{\sum_j [T(d_j, t) \cdot r_{ji} \cdot \phi(r_{ji})]}{\sum_j [T(d_j, t) \cdot \phi(r_{ji})]}$$
- Deviation filter: $\phi(r_{ji}) \approx 0$ if $|r_{ji} - \mu_r| > 2\sigma_r$, otherwise $\phi(r_{ji}) = 1.0$

### 3.3 Composite Trust Score & Latency Harmonization
$$T(d_i, t) = \alpha T_D + \beta T_I + \gamma T_C$$
- Parameters: $\alpha = 0.40, \beta = 0.35, \gamma = 0.25$ ($\alpha + \beta + \gamma = 1.0$)
- Admission Threshold: $\theta = 0.60$
- **Latency Reconciliation**: Standardized end-to-end evaluation latency is **17.8 ms** per node (Table 3, Fig 4, Abstract). Raw MTEE arithmetic calculation is 15.0 ms; ESAD incremental log update adds 2.8 ms, totaling 17.8 ms.

### 3.4 Theoretical 1/3 Collusion Bound vs. 40% Experimental Stress Scenario
- **Theorem 1 Analytical Bound ($f < 1/3 \approx 33.3\%$)**: Provable Byzantine guarantee where honest peer recommendations strictly outvote colluding recommendations without requiring auxiliary behavioral classifiers.
- **Empirical Stress Test ($f = 40.0\%$)**: Deliberate boundary violation where LTMF preserves 89.7% detection accuracy through its orthogonal second layer: ESAD 6D anomaly detection (trust velocity, join/leave frequency, energy profile). Single-layer baselines (BTEM, DTrust) degrade to 68.3%.

### 3.5 ESAD (Edge-Local Sybil Anomaly Detector)
- Feature vector: 6 dimensions (trust velocity, comm frequency, data consistency, recommendation bias, join-leave rate, energy anomaly)
- Trees: $n_{\text{trees}} = 50$
- Window Size: $W_{\text{ESAD}} = 256$ samples (bounds memory to $\le 2.9$ MB)
- Max Depth: $h_{\text{max}} = \lceil \log_2 256 \rceil = 8$
- Incremental update: $O(\log n)$ per sample

### 3.6 DIECP (Distributed Inter-Edge Consensus Protocol)
- Gossip Fanout: $F = \lceil \log_2 M \rceil$ (4 for $M=10$, 5 for $M=20$)
- Target Gossip Rounds: 3 rounds ($<45$ ms convergence)
- Byzantine Message Budget: $2M + 1$ messages per round (vs PBFT $O(M^2)$)
- Byzantine Tolerance: $f_e < \lfloor (M-1)/3 \rfloor$

---

## 4. Parameter Sensitivity Analysis
Key sensitivity insights derived from 30 seeded runs:
1. **Decay Factor ($\lambda = 0.85$)**: Optimal point balancing fast penalty of malicious acts with tolerance to transient wireless packet loss.
2. **Threshold ($\theta = 0.60$)**: Setting $\theta > 0.70$ increases False Positive Rate to 14.3%; setting $\theta < 0.50$ lowers Sybil recall to 82.4%.
3. **ESAD Window ($W = 256$)**: Optimal knee-of-curve preserving 2.9 MB RAM ceiling and 17.8 ms latency. Larger windows ($W=1024$) yield $<1\%$ accuracy gain while doubling latency.
4. **Trust Weight Split ($\alpha=0.40, \beta=0.35, \gamma=0.25$)**: Optimal convex weighting ensuring self-observation robustness ($\alpha$) while preventing recommendation dominance ($\beta \le 0.35$).

---

## 5. Hardware & Emulator Constraints
- **Processor**: Single-core 2.0 GHz virtual CPU clock ceiling.
- **RAM**: Strict 512 MB physical ceiling per edge server.
- **Energy Model**: Raspberry Pi 4 Model B (Quad Cortex-A72 @ 1.5 GHz), active power 4.1 W, idle 2.7 W. Measured LTMF overhead: 1.4 mJ / cycle.
- **Network**: Short-range IEEE 802.15.4 / BLE 5.0 to devices; 100 Mbps meshed edge backhaul with 10 ms base round-trip delay.

---

## 6. Identical Attack Traces & Random Seeds
To ensure statistical rigor and eliminate cross-run environmental variance:
- 30 distinct pseudo-random seeds ($S_0 = 42000, S_1 = 43337, \dots, S_{29} = 80773$) govern graph topology, device behavioral profiles, and attack traces.
- For each seed $S_k$, the identical attack sequence (collusive ballot-stuffing, on-off spoofing, telemetry tampering) is executed sequentially on LTMF, BTEM, DTrust, and SybilEdge.
- All metrics are reported as sample means with 95% confidence intervals ($t_{29, 0.025} = 2.045$).

---

## 7. Security Theorems & Formal Proof Sketches

### Assumptions
- **(A1) Bounded Adversary**: At most $f < 1/3$ of peer recommendation channels within any single evaluation cluster are controlled by colluding Sybils without triggering edge anomaly tripwires.
- **(A2) Non-Zero Honest Interactions**: Any legitimate node interacts with at least $k \ge 3$ distinct honest neighbors over sliding window $W$.
- **(A3) Tamper-Evident Physical Channels**: Edge supervisors can measure physical layer metrics (RSSI variance, packet arrival timing, transmission energy).
- **(A4) Synchronous Gossip Delivery**: Inter-edge gossip rounds complete within bounded time $\Delta t \le 15$ ms over 100 Mbps backhaul.

### Theorem 1 (Collusion Resistance Bound)
*Under Assumptions A1–A3, if the fraction of colluding nodes satisfies $f < 1/3$, the composite trust evaluation satisfies $T(d_{\text{sybil}}, t) < \theta = 0.60$ with probability $1 - \delta$, where $\delta \le \exp(-2 k (\theta - \mu)^2)$.*

**Proof Sketch**:
1. By the $2\sigma$ deviation filter $\phi(r_{ji})$, collusive rating spikes exceeding honest mean by $>2\sigma$ are filtered with weight $\phi = 0.05$.
2. The remaining indirect trust is bounded by $T_I \le \frac{(1-f) T_H + f \cdot \epsilon}{(1-f) + f \cdot \epsilon}$.
3. For $f < 1/3$ and $\beta = 0.35$, the indirect component cannot inflate $T(d_i, t)$ above $\theta = 0.60$ when $T_D \le 0.45$.
4. When $f \ge 1/3$ (e.g., the 40% experimental scenario), the secondary ESAD isolation forest evaluates 6D physical/behavioral vectors where anomalous churn and energy signatures trigger detection with 89.7% accuracy. $\blacksquare$

### Theorem 2 (Consensus Convergence & Byzantine Safety)
*For an edge cluster of $M$ supervisors with at most $f_e < \lfloor (M-1)/3 \rfloor$ Byzantine faulty servers, the DIECP protocol achieves consensus on global blacklist state within $\lceil \log_2 M \rceil$ gossip rounds using at most $(2M + 1)$ messages per round.*

**Proof Sketch**:
1. Each round uses deterministic random fanout $F = \lceil \log_2 M \rceil$.
2. After $r = \lceil \log_2 M \rceil$ rounds, the probability that an honest node has not received the gossip message is $(1 - F/M)^r \le \exp(-r F / M) < 0.01$.
3. Quorum commit requires $2 f_e + 1$ matching digests, preventing Byzantine edge servers from committing conflicting blacklist states. $\blacksquare$

---

## 8. Future Empirical Evaluation Roadmap
To address real-world deployment challenges highlighted in the review, the evaluation roadmap incorporates:
1. **Physical IoT & Edge Testbed**: Deployment on heterogeneous physical hardware (Raspberry Pi 4 Model B, NVIDIA Jetson Nano, ESP32 microcontrollers).
2. **Dynamic Device Mobility**: Integration of Random Waypoint and Manhattan mobility models to assess trust decay under topological churn.
3. **Heterogeneous Wireless Links**: Evaluation under realistic channel degradation (802.15.4 link fading, packet loss rates from 1% to 15%, asymmetric signal propagation).
4. **Large-Scale Network Scaling**: Extending benchmark simulations from 1,000 nodes up to 10,000 nodes across 50 distributed edge clusters.
5. **Adaptive & Sophisticated Adversaries**: Testing against reinforcement learning-driven smart Sybils that dynamically alternate between honest cooperation and collusive sabotage.
