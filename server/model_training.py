import os
import sys
import json
import numpy as np
from keras.models import Sequential
from keras.layers import LSTM, Dropout, Dense, Activation,Input,BatchNormalization
from keras.callbacks import ModelCheckpoint
from keras.utils import to_categorical
import shutil
from keras.optimizers import Adam
from keras.regularizers import l2

def load_data_from_json(model_folder):
    with open(os.path.join(model_folder, 'data', 'prepared_data.json'), 'r') as file:
        data = json.load(file)
        network_input = np.array(data['network_input'])
        network_output = np.array(data['network_output'])
        pitchnames = data['pitchnames']
        n_vocab = data['n_vocab']

    return network_input, network_output, pitchnames, n_vocab

def train_model(model_folder):
    network_input, network_output, pitchnames, n_vocab = load_data_from_json(model_folder)

    # model = Sequential()
    # model.add(Input(shape=(network_input.shape[1], network_input.shape[2])))
    # model.add(Dropout(0.3))
    # model.add(LSTM(512, return_sequences=True))
    # model.add(Dropout(0.3))
    # model.add(LSTM(256))
    # model.add(Dense(256))
    # model.add(Dropout(0.3))
    # model.add(Dense(n_vocab))
    # model.add(Activation('softmax'))
    # model.compile(loss='categorical_crossentropy', optimizer='rmsprop')


    # model = Sequential()
    # model.add(Input(shape=(network_input.shape[1], network_input.shape[2])))
    # model.add(Dropout(0.3))
    # model.add(LSTM(512, return_sequences=True))
    # model.add(Dropout(0.3))
    # model.add(LSTM(512, return_sequences=True))  # Adding another LSTM layer with more units
    # model.add(Dropout(0.3))
    # model.add(LSTM(256))
    # model.add(Dense(512, kernel_regularizer=l2(0.001)))  # Adding L2 regularization to Dense layer
    # model.add(BatchNormalization())  # Adding BatchNormalization layer
    # model.add(Dense(n_vocab))
    # model.add(Activation('softmax'))
    
    # optimizer = Adam(learning_rate=0.001)  # Adjusting learning rate
    # model.compile(loss='categorical_crossentropy', optimizer=optimizer)
    

    model = Sequential()# Input layer
    model.add(Input(shape=(network_input.shape[1], network_input.shape[2])))# Dropout layer to prevent overfitting
    model.add(Dropout(0.3))# First LSTM layer with more units and return sequences
    model.add(LSTM(1024, return_sequences=True))  # Increase the number of units to capture more complex patterns# Dropout layer
    model.add(Dropout(0.3))# Second LSTM layer with more units and return sequences
    model.add(LSTM(1024, return_sequences=True))  # Adding another LSTM layer with more units# Dropout layer
    model.add(Dropout(0.3))# Third LSTM layer with more units
    model.add(LSTM(512))  # Adjust the number of units as needed# Dense layer with regularization and BatchNormalization
    model.add(Dense(512, kernel_regularizer=l2(0.001)))  # Adding L2 regularization to Dense layer
    model.add(BatchNormalization())  # Adding BatchNormalization layer# Activation layer with Tanh activation function
    model.add(Activation('tanh'))  # Use Tanh activation function# Output layer with softmax activation for multi-class classification
    model.add(Dense(n_vocab))
    model.add(Activation('softmax'))# Compile the model with customized optimizer and learning rate
    optimizer = Adam(learning_rate=0.0001)  # Adjusting learning rate
    model.compile(loss='categorical_crossentropy', optimizer=optimizer)


    filepath = 'improve/weights-improvement-{epoch:02d}-{loss:.4f}-bigger.keras'
    checkpoint = ModelCheckpoint(
        filepath, monitor='loss',
        verbose=0,
        save_best_only=True,
        mode='min'
    )
    callbacks_list = [checkpoint]
    model.fit(network_input, network_output, epochs=8, batch_size=64, callbacks=callbacks_list)

    model.save(os.path.join(model_folder, 'trained_model.keras'))  # Save in native Keras format
    shutil.rmtree('improve')
    print("Training completed and model saved.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python model_training.py <model_folder>")
    else:
        model_folder = sys.argv[1]
        train_model(model_folder)
