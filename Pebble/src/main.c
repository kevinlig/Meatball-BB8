#include <pebble.h>

#define HISTORY_MAX 144
#define TRIGGER_MIN 150

static Window *s_main_window;
static TextLayer *s_display_layer;

// this is generic tutorial code to handle sending commands to iOS
static void send(int key, int value) {
    // Create dictionary
    DictionaryIterator *iter;
    app_message_outbox_begin(&iter);

    // Add value to send
    dict_write_int(iter, key, &value, sizeof(int), true);

    // Send dictionary
    app_message_outbox_send();
}

static void main_window_load(Window *window) {
    // Get information about the Window
    Layer *window_layer = window_get_root_layer(window);
    GRect bounds = layer_get_bounds(window_layer);

    // Create the TextLayer with specific bounds
    s_display_layer = text_layer_create(
        GRect(0, PBL_IF_ROUND_ELSE(58, 52), bounds.size.w, 50));

    // Set up the text layer
    text_layer_set_background_color(s_display_layer, GColorClear);
    text_layer_set_text_color(s_display_layer, GColorWhite);
    text_layer_set_text(s_display_layer, "");
    text_layer_set_font(s_display_layer, fonts_get_system_font(FONT_KEY_GOTHIC_18));
    text_layer_set_text_alignment(s_display_layer, GTextAlignmentCenter);

    // Add it as a child layer to the Window's root layer
    layer_add_child(window_layer, text_layer_get_layer(s_display_layer));
}

static void main_window_unload(Window *window) {
    // Destroy TextLayer
    text_layer_destroy(s_display_layer);
}


static void data_handler(AccelData *data, uint32_t num_samples) {
  
    // look only at the Z axis, and compare the first and last sample values
    int delta = abs(data[2].z - data[0].z);
    if (delta > TRIGGER_MIN) {
        // vibes_long_pulse();
        text_layer_set_text(s_display_layer, "TRIGGER");
        send(1, 0);
    }
    else {
        text_layer_set_text(s_display_layer, "");
    }

}

static void outbox_sent_handler(DictionaryIterator *iter, void *context) {
    // Ready for next command
    // APP_LOG(APP_LOG_LEVEL_ERROR, "SENT");
}

static void outbox_failed_handler(DictionaryIterator *iter, AppMessageResult reason, void *context) {
    APP_LOG(APP_LOG_LEVEL_ERROR, "Fail reason: %d", (int)reason);
}

static void init() {
    // Create main Window element and assign to pointer
    s_main_window = window_create();

    // Set handlers to manage the elements inside the Window
    window_set_window_handlers(s_main_window, (WindowHandlers) {
        .load = main_window_load,
        .unload = main_window_unload
    });

    // Show the Window on the watch, with animated=true
    window_stack_push(s_main_window, true);
    // set the background black so it's not annoying	
	window_set_background_color(s_main_window, GColorBlack);

    // Open AppMessage and register callbacks
    app_message_register_outbox_sent(outbox_sent_handler);
    app_message_register_outbox_failed(outbox_failed_handler);

    const int inbox_size = 128;
    const int outbox_size = 128;
    app_message_open(inbox_size, outbox_size);
	
    // set up to receive data from the accelerometer, collect 3 samples at a time
	uint32_t num_samples = 3;
	accel_data_service_subscribe(num_samples, data_handler);
	accel_service_set_sampling_rate(ACCEL_SAMPLING_10HZ);
}

static void deinit() {
    // Destroy Window
    accel_data_service_unsubscribe();
    window_destroy(s_main_window);
}

int main(void) {
    init();
    app_event_loop();
    deinit();
}