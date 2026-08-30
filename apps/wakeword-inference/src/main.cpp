#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>

#include "edge-impulse-sdk/classifier/ei_run_classifier.h"

/*
 * Edge Impulse integration smoke test.
 *
 * Verifies that the generated model and Edge Impulse SDK
 * are available to the Zephyr application.
 */
int main(void)
{
    printk("Zephyr started\n");

    printk("EI input frame size: %d\n", EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE);

    while (1) 
	{
        k_sleep(K_SECONDS(10));
		printk("Still running...\n");
    }

    return 0;
}