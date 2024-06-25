# CNN-Convolution-Engine-Accelerator
Verilog implementation of a fully parameterised (variable feature map and kernel sizes) and pipelined (use shift registers to help in MAC placement and timing) convolution engine accelerator

Key Points:
1. Each MAC unit has fixed weights and feature map is fed as input to perform convolution operation
2. conv
