import os
import sys
import glob
import numpy as np
import json
from music21 import converter, instrument, note, chord
from keras.utils import to_categorical

def prepare_data_and_save(model_folder, midi_folder):
    notes = []
    midi_files = glob.glob(os.path.join(midi_folder, "*.mid"))
    num_files = len(midi_files)

    if num_files == 0:
        print("Error: No MIDI files found in the specified folder.")
        return {"code":False,"msg":"Error: No MIDI files found in the specified folder."}

    for idx, file in enumerate(midi_files):
        print(f"Processing MIDI file {idx + 1}/{num_files}: {file}")
        midi = converter.parse(file)
        notes_to_parse = None
        parts = instrument.partitionByInstrument(midi)
        if parts:
            notes_to_parse = parts.parts[0].recurse()
        else:
            notes_to_parse = midi.flat.notes
        for element in notes_to_parse:
            if isinstance(element, note.Note):
                notes.append(str(element.pitch))
            elif isinstance(element, chord.Chord):
                notes.append('.'.join(str(n) for n in element.normalOrder))

    if not notes:
        print("Error: No notes found in MIDI files.")
        return {"code":False,"msg":"Error: No notes found in MIDI files."}

    sequence_length = 100
    pitchnames = sorted(set(item for item in notes))
    n_vocab = len(pitchnames)
    note_to_int = dict((note, number) for number, note in enumerate(pitchnames))
    network_input = []
    network_output = []

    for i in range(0, len(notes) - sequence_length, 1):
        sequence_in = notes[i:i + sequence_length]
        sequence_out = notes[i + sequence_length]
        network_input.append([note_to_int[char] for char in sequence_in])
        network_output.append(note_to_int[sequence_out])

    n_patterns = len(network_input)
    network_input = np.reshape(network_input, (n_patterns, sequence_length, 1))
    network_input = network_input / float(n_vocab)
    network_output = to_categorical(network_output)

    data = {
        'network_input': network_input.tolist(),
        'network_output': network_output.tolist(),
        'pitchnames': pitchnames,
        'n_vocab': n_vocab
    }

    os.makedirs(os.path.join(model_folder, 'data'), exist_ok=True)
    with open(os.path.join(model_folder, 'data', 'prepared_data.json'), 'w') as file:
        json.dump(data, file)

    print(f"Data preparation completed and saved to '{os.path.join(model_folder, 'data')}'.")
    return {"code":True,"msg":"done"}

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python data_preparation.py <model_folder> <midi_folder>")
    else:
        model_folder = sys.argv[1]
        midi_folder = sys.argv[2]
        prepare_data_and_save(model_folder, midi_folder)
