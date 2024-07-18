# CNN-Convolution-Engine-Accelerator
Verilog implementation of a fully parameterised (variable feature map and kernel sizes) and pipelined (use shift registers to help in MAC placement and timing) convolution engine accelerator

Key Points:
1. Each MAC unit has fixed weights and feature map is fed as input to perform convolution operation
2. valid_conv is used to represent if convolution is valid as in current implentation the convolution operation wraps around the feature map resulting in invalid configuration
3. Preventing this wrap by blocking calculations will stop our pipleing and cause each new convolution to be calculated from scratch (increasing time) or for extra memory to be used
4. pooling code to be uploaded
