from music21 import converter,instrument # or import *
import os
import sys
def convert_instrument(filepath,filename,instrument_name,save_file=False):
    s = converter.parse(filepath)
    for el in s.recurse():
       if 'Instrument' in el.classes:
            el.activeSite.replace(el, getattr(instrument, instrument_name)())    
  
    if save_file:
        midi_file_path = os.path.join('generated_music', 'converted_file.mid')
        s.write('midi', midi_file_path)
        print(f"midi instrument converted saved at: {midi_file_path}")
    else:
        midi_file_path = os.path.join('temp', f'{filename}.mid')
        s.write('midi', midi_file_path)
        print("midi instrument converted. Returend path")
        return midi_file_path


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python music_generation.py <model_folder>")
    else:
        filepath = sys.argv[1]
        instrument_name = sys.argv[2]
        save_file = sys.argv[3]
        convert_instrument(filepath,"pass",instrument_name,save_file)
