#include <zephyr/kernel.h>
#include <stdio.h>
#include "edge-impulse-sdk/classifier/ei_run_classifier.h"
#include "test_audio_okydoky.h"
 

/*
 * Edge Impulse integration smoke test.
 *
 * Verifies that the generated model and Edge Impulse SDK
 * are available to the Zephyr application.
 */

// Callback function declaration
static int get_signal_data(size_t offset, size_t length, float *out_ptr);

int main(int argc, char **argv) {

    signal_t signal;            // Wrapper for raw input buffer
    ei_impulse_result_t result; // Used to store inference output
    EI_IMPULSE_ERROR res;       // Return code from inference

   int buf_len = sizeof(test_audio_okydoky) / sizeof(test_audio_okydoky[0]);

    // Make sure that the length of the buffer matches expected input length
    if (buf_len != EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE) {
            printf("ERROR: input size is wrong\n");
            printf("Expected %d samples, got %d\n",
                EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE,
                (int)buf_len);
            return 1;
    }
    // Assign callback function to fill buffer used for preprocessing/inference
    signal.total_length = buf_len;
    signal.get_data = &get_signal_data;

    // Perform DSP pre-processing and inference
    res = run_classifier(&signal, &result, false);

    // Print return code and how long it took to perform inference
    printf("run_classifier returned: %d\r\n", res);
    printf("Timing: DSP %d ms, inference %d ms, anomaly %d ms\r\n",
            result.timing.dsp,
            result.timing.classification,
            result.timing.anomaly);

    // Print the prediction results (classification)
    printf("Predictions:\r\n");
    for (uint16_t i = 0; i < EI_CLASSIFIER_LABEL_COUNT; i++) {
        printf("  %s: ", ei_classifier_inferencing_categories[i]);
        printf("%.5f\r\n", (double)result.classification[i].value);
    }
    return 0;
}

// Callback: fill a section of the out_ptr buffer when requested
static int get_signal_data(size_t offset, size_t length, float *out_ptr) {
    for (size_t i = 0; i < length; i++) {
        out_ptr[i] = test_audio_okydoky[offset + i];
    }

    return EIDSP_OK;
}