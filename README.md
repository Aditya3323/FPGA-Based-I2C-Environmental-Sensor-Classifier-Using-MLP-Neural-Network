## FPGA-Based I2C Environmental Sensor Classifier Using MLP Neural Network

This project implements a hardware-accelerated multi-layer perceptron (MLP) neural network on an FPGA to classify environmental conditions using data from four I2C digital sensors:

 - SHT31 – Temperature & Humidity

 - CCS811 – Air Quality (VOC / eCO₂)

 - LPS22HB – Pressure

 - BH1750 – Ambient Light

The FPGA collects raw sensor readings via a custom I2C master controller, performs preprocessing and feature scaling, and feeds the data into an MLP neural network, which classifies the environment into one of five states:

 - Normal -> [1,0,0,0,0]	-> Healthy environment
 - Humid	->[0,1,0,0,0]	-> High humidity
 - Overheated -> [0,0,1,0,0]	-> High temperature
 - Poor Air ->	[0,0,0,1,0] -> VOC/eCO₂ level high
 - Low Light	-> [0,0,0,0,1] -> Very low illumination

## 📌 Features

 - Custom Verilog I2C Master supporting multiple sensors on the same bus

 - Real-time sensor polling

 - Fixed-point MLP neural network implemented fully in FPGA logic

 - Configurable hidden layers & weights

 - Low-latency classification output

 - Modular design for easy integration into bigger FPGA systems

## 🧠 Neural Network Architecture

A typical configuration used in this project:

 - Input Layer: 4 features (Temp, Humidity, Pressure, Light)

 - Hidden Layer: 8 neurons

 - Output Layer: 5 neurons

 - Activation: ReLU

 - Weights: Signed fixed-point (16-bit)

## 🚀 How It Works

 - Sensors → I2C Bus → FPGA
    FPGA reads sensor outputs using custom I2C drivers.

 - MLP Inference
    Inputs fed into the MLP core.
    Parallel MAC units compute activations.
    Outputs represent classification scores.

 - Environment Classification
    Highest-score neuron determines the environmental state.
