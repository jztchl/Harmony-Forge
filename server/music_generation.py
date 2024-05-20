import os
import sys
import numpy as np
import json
from keras.models import load_model
from music21 import stream, note, chord, instrument,converter

def generate_music(model_folder,filename, duration_seconds=10, temperature=1.0, tempo=120, instrument_name='Piano',save_file=False):
    data_file = os.path.join(model_folder, 'data', 'prepared_data.json')
    with open(data_file, 'r') as file:
        data = json.load(file)
        network_input = np.array(data['network_input'])
        pitchnames = data['pitchnames']
        n_vocab = data['n_vocab']

    # Load the trained model in the native Keras format
    model_file = os.path.join(model_folder, 'trained_model.keras')
    model = load_model(model_file)  # Load the model

    start = np.random.randint(0, len(network_input)-1)
    int_to_note = dict((number, note) for number, note in enumerate(pitchnames))
    pattern = list(map(float, network_input[start]))  # Convert each element to float
    prediction_output = []

    total_beats = (2*duration_seconds) * tempo / 60  # Calculate total beats based on tempo and duration
    notes_generated = 0  # Counter for notes generated

    # Generate notes
    for _ in range(int(total_beats)):
        progress = (notes_generated / total_beats) * 100
        print(f"Generating music: {progress:.2f}% complete", end='\r')
        prediction_input = np.reshape(pattern, (1, len(pattern), 1))
        prediction_input = prediction_input / float(n_vocab)
        prediction = model.predict(prediction_input, verbose=0)
        
        # Apply temperature for more varied predictions
        prediction = np.log(prediction) / temperature
        exp_preds = np.exp(prediction)
        prediction = exp_preds / np.sum(exp_preds)
        
        # Select index based on probability distribution
        index = np.random.choice(len(prediction[0]), p=prediction[0])
        result = int_to_note[index]
        prediction_output.append(result)
        pattern.append(index / float(n_vocab))  # Update pattern for next iteration
        pattern = pattern[1:]  # Shift pattern by removing the first element

        notes_generated += 1  # Increment counter for notes generated

    print("\nNotes generation completed.")
    
    # Create notes, chords, and write to MIDI stream
    offset = 0
    output_notes = []

    for pattern in prediction_output:
        if ('.' in pattern) or pattern.isdigit():
            notes_in_chord = pattern.split('.')
            notes = []
            for current_note in notes_in_chord:
                new_note = note.Note(int(current_note))
                notes.append(new_note)
            new_chord = chord.Chord(notes)
            new_chord.offset = offset
            output_notes.append(new_chord)
        else:
            new_note = note.Note(pattern)
            new_note.offset = offset
            output_notes.append(new_note)
        offset += 0.5
    print("\nChords generation completed.")
    # Create MIDI stream and write to file
    midi_stream = stream.Stream(output_notes)
    print("\nChanging Instrument")
    midi_file_path = os.path.join('temp', f'{filename}.mid')
    midi_stream.write('midi', fp=midi_file_path)
    s = converter.parse(midi_file_path)
    for el in s.recurse():
        if 'Instrument' in el.classes:
            el.activeSite.replace(el, getattr(instrument, instrument_name)())

    if save_file:
        midi_file_path = os.path.join('generated_music', 'test_output.mid')
        s.write('midi', midi_file_path)
       
        print(f"MIDI file saved at: {midi_file_path}")
    else:
        midi_file_path = os.path.join('temp', f'{filename}.mid')
        s.write('midi', midi_file_path)
        print("MIDI data generated. Returend path")
        return midi_file_path

if __name__ == "__main__":
    if len(sys.argv) != 7:
        print("Usage: python music_generation.py <model_folder>")
    else:
        model_folder = sys.argv[1]
        duration_seconds = sys.argv[2]
        temperature = sys.argv[3]
        tempo = sys.argv[4]
        instrument_name=sys.argv[5]
        save_file = sys.argv[6]
        generate_music(model_folder,"temp", duration_seconds=int(duration_seconds), temperature=float(temperature), tempo=int(tempo), instrument_name=instrument_name,save_file=save_file)
