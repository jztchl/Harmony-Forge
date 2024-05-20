import os
import sys
import json
import numpy as np
from keras.models import load_model
from keras.callbacks import ModelCheckpoint
import shutil
import tensorflow as tf

def load_data_from_json(model_folder):
    with open(os.path.join(model_folder, 'data', 'prepared_data.json'), 'r') as file:
        data = json.load(file)
        network_input = np.array(data['network_input'])
        network_output = np.array(data['network_output'])
        pitchnames = data['pitchnames']
        n_vocab = data['n_vocab']

    return network_input, network_output, pitchnames, n_vocab

def fine_tune_model(model_folder):
    network_input, network_output, pitchnames, n_vocab = load_data_from_json(model_folder)

    # Load the pre-trained model for fine-tuning
    model_file = os.path.join(model_folder, 'trained_model.keras')
    model = load_model(model_file)
    print("Loaded pre-trained model for fine-tuning.")

    # Define callbacks for model checkpoint
    filepath = 'improve/weights-improvement-{epoch:02d}-{loss:.4f}-bigger.keras'
    checkpoint = ModelCheckpoint(
        filepath, monitor='loss',
        verbose=0,
        save_best_only=True,
        mode='min'
    )
    callbacks_list = [checkpoint]

    # Fine-tune the model
    model.fit(network_input, network_output, epochs=5, batch_size=64, callbacks=callbacks_list)

    # Save the fine-tuned model
    model.save(os.path.join(model_folder, 'trained_model_fine_tuned.keras'))

    # Convert the Keras model to TensorFlow Lite with full integer quantization
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]

    # Define a representative dataset for quantization (replace with your actual data)
    def representative_dataset():
        for _ in range(100):
            input_data = np.random.rand(1, *network_input.shape[1:])
            yield [input_data.astype(np.float32)]

    converter.representative_dataset = representative_dataset

    try:
        # Convert the model
        tflite_model = converter.convert()

        # Save the TensorFlow Lite model
        tflite_model_file = os.path.join(model_folder, 'trained_model_fine_tuned.tflite')
        with open(tflite_model_file, 'wb') as f:
            f.write(tflite_model)

        shutil.rmtree('improve')
        print("Fine-tuning and conversion to TensorFlow Lite completed.")
        print(f"TensorFlow Lite model saved: {tflite_model_file}")
    except Exception as e:
        print("Error occurred during TensorFlow Lite conversion:")
        print(e)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python fine_tune_model.py <model_folder>")
        sys.exit(1)

    model_folder = sys.argv[1]
    fine_tune_model(model_folder)
