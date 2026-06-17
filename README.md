# Belief Propagation for Stereo Matching (Sum-Product, Max-Product, Min-Sum)

MATLAB implementations of Loopy Belief Propagation (LBP) for stereo matching, featuring Sum-Product, Max-Product and Min-Sum message-passing algorithms for disparity estimation.

## Features

Belief Propagation variants:

1. **Sum-Product**
2. **Max-Product**
3. **Min-Sum**

The message is updated using **convolution** on the (product or sum of) **incoming messages** and the **smoothness function**.

- **Sum-Product** uses the **standard convolution** (sum-product convolution)
- **Max-Product** uses the **max-convolution** (max-product convolution)
- **Min-Sum** uses the **min-convolution** (min-sum convolution)

Two different computation methods (standard and low memory).

The algorithms are optimized for performance using matrix operations and other techniques.

## Algorithms

| Number | Algorithm | Variant | MATLAB Implementation |
| --- | --- | --- | --- |
| 1 | Belief Propagation | **Sum-Product** | **[`SumProduct.m`](./SumProduct.m)** |
| 2 | Belief Propagation | **Max-Product** | **[`MaxProduct.m`](./MaxProduct.m)** |
| 3 | Belief Propagation | **Min-Sum** | **[`MinSum.m`](./MinSum.m)** |

## Installation

Download the project as ZIP file, unzip it, and run the scripts.

## Usage

A stereo matching algorithm works with stereo image pairs to produce disparity maps.
This project contains three MATLAB scripts, each implementing a stereo matching algorithm (Belief Propagation variants). The files `left.png` and `right.png` contain the stereo image pair used as input.
To use a different stereo pair, replace these two images with your own. In this case, you must also adjust the **disparity levels** parameter in the script you are running.
You may optionally modify other parameters as needed. If the input images contain little or no noise, it is recommended not to use the Gaussian filter.

## Results

Below are the disparity maps produced from the **Tsukuba stereo pair**.

![Tsukuba Left](Left.png) ![Tsukuba Right](Right.png)

### Belief Propagation (Sum-Product)

![Belief Propagation Sum-Product Disparity Map](results/disparity_SumProduct.png)

### Belief Propagation (Max-Product)

![Belief Propagation Max-Product Disparity Map](results/disparity_MaxProduct.png)

### Belief Propagation (Min-Sum)

![Belief Propagation Min-Sum Disparity Map](results/disparity_MinSum.png)

## Links

### Project Repository
- [Belief Propagation for Stereo Matching (Sum-Product, Max-Product, Min-Sum)](https://github.com/aposb/belief-propagation-for-stereo)

### Related Projects
- [Stereo Matching Algorithms in MATLAB and Python](https://github.com/aposb/stereo-matching-algorithms)
- [Basic Stereo Algorithms (Evolution)](https://github.com/aposb/stereo-algorithms-evolution)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
