#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer InputDataBuffer {
  int data[];
} buffer_input;

layout(set = 1, binding = 0, std430) restrict buffer OutputDataBuffer {
  int data[];
} buffer_output;

int height = 256;
int width = 256;

// The code we want to execute in each invocation
void main() {
  // gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups
  int globalIndex = int(gl_GlobalInvocationID.x);
  int curr = int(buffer_input.data[gl_GlobalInvocationID.x]);
  int row = int(globalIndex / width);
  int col = globalIndex % width;

  int sum = 0;
  for (int xi = -1; xi <= 1; xi++) {
    for (int yi = -1; yi <= 1; yi++) {
      int xx = xi + col;
      int yy = yi + row;
      if (xx >= 0 && xx < width) {
        if (yy >= 0 && yy < height) {
          int targetIndex = yy * width + xx;
          sum = sum + buffer_input.data[targetIndex];
        }
      }
    }
  }

  buffer_output.data[gl_GlobalInvocationID.x] = sum;
  // if (sum > 3) {
  //   buffer_output.data[gl_GlobalInvocationID.x] = 0;
  // }
  // else if (sum > 0) {
  //   buffer_output.data[gl_GlobalInvocationID.x] = 1;
  // }
  // else {
  //   buffer_output.data[gl_GlobalInvocationID.x] = 0;
  // }
}
