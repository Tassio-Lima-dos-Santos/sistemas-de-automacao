# Automated Manufacturing Line – PLC & Factory I/O

## 🔍 Project Overview

This repository documents an **automated industrial production line** developed using **CODESYS (Structured Text)** and **Factory I/O**, controlled by a PLC via **Modbus communication**.

The project simulates a **complete manufacturing workflow**, from raw item generation to final packaging of machined parts. It was designed not as a simple academic exercise, but as a **robust, modular and industry-oriented automation system**.

> **Output of the system:** wooden boxes containing machined parts, separated by material (plastic or metal), with a configurable number of items per box.

---

## 🏭 Industrial Plant Description (Factory I/O)

### 1. Input & Classification Section

The production line starts with an **item generator**, responsible for feeding the system with:

* Raw plastic parts (blue and green)
* Raw metal parts
* Cardboard boxes (waste material)

These items are transported by the **first conveyor belt**, which includes:

* A **mechanical alignment structure** to standardize item orientation
* A **capacitive sensor** to detect the presence of any item
* An **inductive sensor** to identify metallic items

This section performs the **initial classification** of all incoming items.

---

### 2. Weighing & Cardboard Disposal

At the end of the first conveyor, items are transferred to a **weighing station**, composed of:

* A dedicated conveyor belt
* An **optical sensor** to detect when an item is on the scale
* A **pneumatic piston** with two end-of-stroke sensors

All items are weighed, and based on the measured value:

* **Cardboard boxes are identified and discarded** using the pneumatic actuator
* Plastic and metal parts proceed further into the line

---

### 3. Manufacturing Cell (Robotic Machining)

After weighing, accepted items move to a second conveyor, equipped with an optical sensor at its end, which feeds a **manufacturing cell**.

The cell contains:

* A **robotic arm**
* A **machining center**

The robotic arm is responsible for:

* Picking raw plastic and metal parts
* Loading them into the machining center
* Unloading machined parts after processing
* Placing machined parts onto the next conveyor

This stage transforms raw items into **finished, machined components**.

---

### 4. Sorting & Packaging (Gantry CNC)

Machined items are transported by a **fourth conveyor belt**, also equipped with an optical sensor at its end.

A **3-axis CNC gantry** with a suction gripper is used to:

* Pick items from the end of the conveyor
* Identify successful gripping via a suction sensor
* Place items into **wooden boxes** on two separate conveyors:

  * One dedicated to **plastic parts**
  * One dedicated to **metal parts**

Each box is filled with a **configurable number of items (default: 3)**. Once full:

* The conveyor moves the filled box forward
* A new empty box is positioned automatically

This marks the **end of the production line**.

---

## ⚙️ System Behavior & Control Philosophy

* The system operates as a **hybrid control system**:

  * **Continuous** (conveyors and production flow)
  * **Event-driven** (sensor triggers, state transitions)

* All decisions (classification, routing, packaging) are **fully automatic**

* The only manual configuration is the **number of items per box**, which can be set **offline**, before operation

---

## 🧠 Control Architecture

The PLC software is structured around **four finite state machines (FSMs)**:

1. **Item Classification FSM**
   Handles detection, weighing, material identification and cardboard disposal

2. **Machining Cell FSM**
   Controls robot–machine interaction and machining workflow

3. **Packaging FSM**
   Manages gantry operation, material-based sorting and box filling

4. **Supervisory FSM**
   Coordinates the other three FSMs, handling synchronization, startup, reset and global states

### Software Organization

* `PLC_PRG`: Main control logic and FSM execution
* Global Variables (GVL): Shared system states, sensors and actuators
* Functions & Function Blocks: Reusable logic and encapsulated behaviors

This modular approach improves:

* Readability
* Maintainability
* Scalability

---

## 🔌 PLC ↔ Factory I/O Integration

* **Communication protocol:** Modbus
* Digital and analog signals mapped between Factory I/O and the PLC
* Special attention given to:

  * Data consistency
  * Timing and synchronization
  * Reliable sensor-actuator interaction

---

## 🛑 Safety, Robustness & Fault Handling

The system includes:

* Safe initialization sequence
* Manual and automatic reset
* Emergency stop triggered by:

  * Physical emergency button
  * Abnormal sensor inactivity (timeout-based fault detection)
* Controlled recovery to a safe state

The project was designed with **industrial robustness** in mind and could be adapted to a real plant with minimal changes.

---

## 🎥 Media & Demonstrations

### ▶️ Full Process Walkthrough

> *Video following a single item through classification, machining and packaging.*

📌 **Insert video here**

---

### ▶️ Production Line Overview

> *Wide-angle view of the entire line operating continuously.*

📌 **Insert video here**

---

### 🖼️ Screenshots

> *Key moments and subsystems of the Factory I/O plant.*

📌 **Insert images here**

---

## 🚀 Possible Improvements

* HMI / SCADA integration
* Production metrics and logging
* Predictive fault detection
* Support for additional materials

---

## 👤 Author

**Tassio Lima dos Santos**

Control and Automation Engineering – UFSC

---

## 📄 Notes

Many files and variables names and all comments are written in portuguese, which is my native language.

This project is part of a personal engineering portfolio and demonstrates practical skills in:

* PLC programming (Structured Text)
* Industrial automation architecture
* Factory I/O simulation
* Robust control system design
