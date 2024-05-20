import os
import sys
import numpy as np
import json
from keras.models import load_model
from music21 import stream, note, chord, instrument, converter

def generate_multi_music(model_folder, filename, duration_seconds=10, temperature=1.0, tempo=120, instrument_names=['Acoustic Grand Piano'], save_file=False):
    data_file = os.path.join(model_folder, 'data', 'prepared_data.json')
    with open(data_file, 'r') as file:
        data = json.load(file)
        network_input = np.array(data['network_input'])
        pitchnames = data['pitchnames']
        n_vocab = data['n_vocab']

    model_file = os.path.join(model_folder, 'trained_model.keras')
    model = load_model(model_file)

    start = np.random.randint(0, len(network_input)-1)
    int_to_note = dict((number, note) for number, note in enumerate(pitchnames))
    patterns = [list(map(float, network_input[start])) for _ in range(len(instrument_names))]
    prediction_outputs = [[] for _ in range(len(instrument_names))]

    total_beats = (2 * duration_seconds) * tempo / 60
    notes_generated = [0] * len(instrument_names)

    for _ in range(int(total_beats)):
        for i in range(len(instrument_names)):
            progress = (notes_generated[i] / total_beats) * 100
            print(f"Generating music for {instrument_names[i]}: {progress:.2f}% complete", end='\r')
            pattern = patterns[i]
            prediction_input = np.reshape(pattern, (1, len(pattern), 1))
            prediction_input = prediction_input / float(n_vocab)
            prediction = model.predict(prediction_input, verbose=0)

            prediction = np.log(prediction) / temperature
            exp_preds = np.exp(prediction)
            prediction = exp_preds / np.sum(exp_preds)

            index = np.random.choice(len(prediction[0]), p=prediction[0])
            result = int_to_note[index]
            prediction_outputs[i].append(result)
            pattern.append(index / float(n_vocab))
            pattern = pattern[1:]

            notes_generated[i] += 1

    print("\nNotes generation completed.")

    final_stream = stream.Score()
    midi_channels = list(range(1, len(instrument_names) + 1))

    for instrument_name, prediction_output, midi_channel in zip(instrument_names, prediction_outputs, midi_channels):
        output_notes = []
        offset_increment = 60 / tempo

        for pattern in prediction_output:
            offset = len(output_notes) * offset_increment
            if '.' in pattern or pattern.isdigit():
                notes_in_chord = pattern.split('.')
                notes = [note.Note(int(current_note)) for current_note in notes_in_chord]
                new_chord = chord.Chord(notes)
                new_chord.offset = offset
                output_notes.append(new_chord)
            else:
                note_obj = note.Note(pattern)
                note_obj.offset = offset
                output_notes.append(note_obj)

        instrument_part = stream.Part()
        for notee in output_notes:
            instrument_part.append(notee)

        instrument_part.insert(0, instrument.fromString(instrument_name))
        instrument_part.partName = instrument_name
        final_stream.append(instrument_part)

    if save_file:
        midi_file_path = os.path.join('generated_music', 'test_output.mid')
        final_stream.write('midi', fp=midi_file_path)
        print(f"MIDI file saved at: {midi_file_path}")
    else:
        midi_file_path = os.path.join('temp', f'{filename}.mid')
        final_stream.write('midi', fp=midi_file_path)
        print("MIDI data generated. Returned path")
        return midi_file_path
# if __name__ == "__main__":
#     if len(sys.argv) != 7:
#         print("Usage: python music_generation.py <model_folder>")
#     else:
#         model_folder = sys.argv[1]
#         duration_seconds = sys.argv[2]
#         temperature = sys.argv[3]
#         tempo = sys.argv[4]
#         instrument_names = sys.argv[5].split(',')
#         save_file = sys.argv[6]
#         generate_music(model_folder, duration_seconds=int(duration_seconds), temperature=float(temperature), tempo=int(tempo), instrument_names=instrument_names, save_file=save_file)
# generate_multi_music('models/mix', duration_seconds=20, temperature=0.1, tempo=120, instrument_names=['Electric Guitar','Electric Bass','Snare Drum',
# 'Bass Drum','Cymbals','Electric Piano'], save_file=True)