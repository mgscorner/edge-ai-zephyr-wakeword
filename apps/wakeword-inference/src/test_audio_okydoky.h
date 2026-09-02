#pragma once
#include <stddef.h>
// Raw audio input is provided as float32.
// Edge Impulse performs preprocessing and feeds the INT8-quantized model internally.
static const float test_audio_okydoky[] = {
    0.00378418f,
    //... Add audio samples here...
    0.09426880f,
    0.09860229f
};

