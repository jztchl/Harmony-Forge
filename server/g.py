import tkinter as tk
from tkinter import messagebox
from tkinter import filedialog
import subprocess

class MusicGenerationGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Music Generation System")
        self.root.geometry("600x400")

        self.model_name_label = tk.Label(root, text="Enter model name:")
        self.model_name_label.pack()
        self.model_name_entry = tk.Entry(root, width=50)
        self.model_name_entry.pack()

        self.model_folder_label = tk.Label(root, text="Select or create a model folder:")
        self.model_folder_label.pack()
        self.model_folder_entry = tk.Entry(root, width=50)
        self.model_folder_entry.pack()
        self.browse_model_folder_button = tk.Button(root, text="Browse", command=self.browse_model_folder)
        self.browse_model_folder_button.pack()

        self.midi_folder_label = tk.Label(root, text="Select MIDI files folder:")
        self.midi_folder_label.pack()
        self.midi_folder_entry = tk.Entry(root, width=50)
        self.midi_folder_entry.pack()
        self.browse_midi_folder_button = tk.Button(root, text="Browse", command=self.browse_midi_folder)
        self.browse_midi_folder_button.pack()

        self.prepare_data_button = tk.Button(root, text="Prepare Data", command=self.prepare_data)
        self.prepare_data_button.pack()

        self.train_model_button = tk.Button(root, text="Train Model", command=self.train_model)
        self.train_model_button.pack()

        self.duration_label = tk.Label(root, text="Desired duration in seconds:")
        self.duration_label.pack()
        self.duration_entry = tk.Entry(root, width=10)
        self.duration_entry.pack()

        self.temperature_label = tk.Label(root, text="Temperature (1.0 for default, lower for less randomness):")
        self.temperature_label.pack()
        self.temperature_entry = tk.Entry(root, width=10)
        self.temperature_entry.pack()

        self.tempo_label = tk.Label(root, text="Tempo (beats per minute):")
        self.tempo_label.pack()
        self.tempo_entry = tk.Entry(root, width=10)
        self.tempo_entry.pack()

        self.generate_music_button = tk.Button(root, text="Generate Music", command=self.generate_music)
        self.generate_music_button.pack()

    def browse_model_folder(self):
        model_folder = filedialog.askdirectory()
        if model_folder:
            self.model_folder_entry.delete(0, tk.END)
            self.model_folder_entry.insert(0, model_folder)

    def browse_midi_folder(self):
        midi_folder = filedialog.askdirectory()
        if midi_folder:
            self.midi_folder_entry.delete(0, tk.END)
            self.midi_folder_entry.insert(0, midi_folder)

    def prepare_data(self):
        model_name = self.model_name_entry.get()
        model_folder = self.model_folder_entry.get()
        midi_folder = self.midi_folder_entry.get()

        if not model_name or not model_folder or not midi_folder:
            messagebox.showerror("Error", "Please fill in all fields.")
            return

        subprocess.Popen(['python', 'data_preparation.py', model_folder, midi_folder])

    def train_model(self):
        model_name = self.model_name_entry.get()
        model_folder = self.model_folder_entry.get()

        if not model_name or not model_folder:
            messagebox.showerror("Error", "Please fill in all fields.")
            return

        subprocess.Popen(['python', 'model_training.py', model_folder])

    def generate_music(self):
        model_name = self.model_name_entry.get()
        model_folder = self.model_folder_entry.get()
        duration = self.duration_entry.get()
        temperature = self.temperature_entry.get()
        tempo = self.tempo_entry.get()

        if not model_name or not model_folder or not duration or not temperature or not tempo:
            messagebox.showerror("Error", "Please fill in all fields.")
            return

        subprocess.Popen(['python', 'music_generation.py', model_folder, duration, temperature, tempo])

if __name__ == "__main__":
    root = tk.Tk()
    app = MusicGenerationGUI(root)
    root.mainloop()
