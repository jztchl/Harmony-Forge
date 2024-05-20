import os
instruments_tuple = (
    'Accordion', 'AcousticBass', 'AcousticGuitar', 'Agogo', 'Alto', 'AltoSaxophone', 
    'Bagpipes', 'Banjo', 'Baritone', 'BaritoneSaxophone', 'Bass', 'BassClarinet', 
    'BassDrum', 'BassTrombone', 'Bassoon', 'BongoDrums', 'BrassInstrument', 
    'Castanets', 'Celesta', 'Choir', 'ChurchBells', 'Clarinet', 'Clavichord', 
    'Conductor', 'CongaDrum', 'Contrabass', 'Contrabassoon', 'Cowbell', 'CrashCymbals', 
    'Cymbals', 'Dulcimer', 'ElectricBass', 'ElectricGuitar', 'ElectricOrgan', 
    'ElectricPiano', 'EnglishHorn', 'FingerCymbals', 'Flute', 'FretlessBass', 
    'Glockenspiel', 'Gong', 'Guitar', 'Handbells', 'Harmonica', 'Harp', 'Harpsichord', 
    'HiHatCymbal', 'Horn', 'Kalimba', 'KeyboardInstrument', 'Koto', 'Lute', 'Mandolin', 
    'Maracas', 'Marimba', 'MezzoSoprano', 'Oboe', 'Ocarina', 'Organ', 'PanFlute', 
    'Percussion', 'Piano', 'Piccolo', 'PipeOrgan', 'PitchedPercussion', 'Ratchet', 
    'Recorder', 'ReedOrgan', 'RideCymbals', 'Sampler', 'SandpaperBlocks', 'Saxophone', 
    'Shakuhachi', 'Shamisen', 'Shehnai', 'Siren', 'Sitar', 'SizzleCymbal', 'SleighBells', 
    'SnareDrum', 'Soprano', 'SopranoSaxophone', 'SplashCymbals', 'SteelDrum', 
    'StringInstrument', 'SuspendedCymbal', 'Taiko', 'TamTam', 'Tambourine', 
    'TempleBlock', 'Tenor', 'TenorDrum', 'TenorSaxophone', 'Timbales', 'Timpani', 
    'TomTom', 'Triangle', 'Trombone', 'Trumpet', 'Tuba', 'TubularBells', 'Ukulele', 
    'UnpitchedPercussion', 'Vibraphone', 'Vibraslap', 'Viola', 'Violin', 'Violoncello', 
    'Vocalist', 'Whip', 'Whistle', 'WindMachine', 'Woodblock', 'WoodwindInstrument', 
    'Xylophone'
)

def create_model_folder(model_name):
    model_folder = f"models/{model_name}"
    os.makedirs(model_folder, exist_ok=True)
    return model_folder

def prepare_data(model_folder, midi_folder):
    data_preparation_script = "data_preparation.py"
    os.system(f"python {data_preparation_script} {model_folder} {midi_folder}")

def train_model(model_folder):
    model_training_script = "model_training.py"
    os.system(f"python {model_training_script} {model_folder}")


def generate_music(model_folder, duration_seconds, temperature, tempo, instrument_name):
    music_generation_script = "music_generation.py"
    os.system(f"python {music_generation_script} {model_folder} {duration_seconds} {temperature} {tempo} {instrument_name} True")

def available_model_folders():
    model_folders = []
    for folder in os.listdir('models'):
        if os.path.isdir(os.path.join('models', folder)):
            model_folders.append(folder)
    print(model_folders)

def convert_instrument(file_path,instrument_name):
    convert_instrument_script="convert_instrument.py"
    os.system(f"python {convert_instrument_script} {file_path} {instrument_name} True")



def main():
    while True:
        print("\n1. Create Model Folder")
        print("2. Prepare Data")
        print("3. Train Model")
        print("4. Generate Music")
        print("5. List available models")
        print("6. List available instruments")
        print("7. Convert instrument")
        print("8. Exit")
        
        choice = input("\nEnter your choice (1-6): ")

        if choice == '1':
            model_name = input("Enter model name: ")
            model_folder = create_model_folder(model_name)
            print(f"Model folder created: {model_folder}")


        elif choice == '2':
            model_name = input("Enter model name: ")
            model_folder = f"models/{model_name}"
            midi_folder = input("Enter MIDI files folder: ")
            prepare_data(model_folder, midi_folder)


        elif choice == '3':
            model_name = input("Enter model name: ")
            model_folder = f"models/{model_name}"
            train_model(model_folder)


        elif choice == '4':
            model_name = input("Enter model name: ")
            model_folder = f"models/{model_name}"
            duration_seconds = int(input("Enter desired duration in seconds: "))
            temperature = float(input("Enter temperature (1.0 for default, lower for less randomness): "))
            tempo = int(input("Enter tempo (beats per minute): "))
            instrument_name=input("Enter Instrument:")
            generate_music(model_folder, duration_seconds, temperature, tempo,instrument_name)


        elif choice == '5':
            available_model_folders()


        elif choice == '6':
            print("available instruments")
            print(instruments_tuple)


        elif choice == '7':
            print("convert instruments")
            file_path = input("Enter file path: ")
            instrument_name=input("Enter instrument name: ")
            convert_instrument(file_path,instrument_name)
            

        elif choice == '8':
            print("Exiting...")
            break
        else:
            print("Invalid choice. Please enter a number from 1 to 7.")

if __name__ == "__main__":
    main()
