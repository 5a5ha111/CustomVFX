![Watefall](https://habrastorage.org/getpro/habr/upload_files/e7b/66e/b78/e7b66eb786379100e090c17f96ddfb47.gif)

# Overview
This system provides an efficient alternative to traditional Particle Systems by leveraging GPU capabilities for all calculations and rendering. Designed for both Android and iOS platforms, it offers significant performance benefits and customization options, with some limitations to consider for specific use cases.


## Advantages
### Cross-Platform Compatibility
The system is compatible with both Android and iOS devices. Unlike many other solutions that rely heavily on compute shaders, which are not universally supported or perform poorly on some mobile devices, this system ensures a more consistent performance across different platforms. This makes it a reliable choice for developers targeting a broad mobile audience.

### High Performance
Based on my tests, this system demonstrates approximately **11%** better performance compared to traditional Particle Systems, achieving around 410 FPS on an empty scene versus 360 FPS with Particle Systems under ideal conditions. This performance gain can be even more significant if the CPU is heavily loaded, making it a superior option for resource-intensive applications.

### Flexible Customization
The system allows for extensive customization, making it easy to add features like color changes based on speed or collision with specific planes. This flexibility enables developers to tailor the visual effects to their specific needs without significant overhead, providing a highly adaptable solution for a wide range of applications.

## Disadvantages
One of the main drawbacks of this system is that it only works with 2D images and does not support mesh spawning.

### Collision Handling
The system is not well-suited for handling collisions with the external environment. If particles need to bounce off all surrounding walls, developers will need to implement additional scripts to pass information about external objects, leading to potential complexity and increased development time. But this is possible after all.


## Technical Breakdown
### Understanding Particle System in VFX Graph
Compute shaders are essential for the VFX Graph as they create necessary information about triangles and vertices in the GPU buffers for rendering, generating them as needed. Since these operations are handled by shaders, information transfer within the GPU is significantly faster than between the CPU and GPU. This efficiency is a key factor in the performance advantages offered by the VFX Graph.

### Particle System Operations on the CPU
The Particle System performs almost all tasks related to spatial positioning and particle creation on the CPU. This allows it to handle collisions with colliders effectively, as the CPU is responsible for physics calculations. This system excels when a small number of particles with physics are required. However, if physics is unnecessary or can be limited to one or a few objects, the GPU's ability to execute numerous repetitive tasks quickly surpasses the CPU.

### This single shader system
Instead of creating particles using the CPU or compute shaders, this system utilizes a single mesh composed of rectangles, each with a predefined unique color serving as an identifier. Since the mesh preexists, no CPU effort is spent on particle creation, allowing for more efficient processing and rendering.

# Conclusion
This GPU-based system offers a **mobile-optimized alternative** to traditional Particle Systems, providing:
- Superior performance for 2D effects
- Extensive customization capabilities
- Cross-platform reliability


