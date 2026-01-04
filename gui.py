#!/usr/bin/env python3
"""
Simple Tkinter GUI wrapper for adv_audio_scrub.

Features:
 - Add files via file picker
 - Remove selected
 - Start processing (runs in thread)
 - Progress bar (per-file)
 - Log window
"""
import os
import threading
import queue
import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
from adv_audio_scrub import rerecord, neural_scrub, CODEC_BITRATE, VIRTUAL_OUTPUT_NAME, VIRTUAL_INPUT_NAME

APP_TITLE = "Advanced Audio Scrub"

class App:
    def __init__(self, root: tk.Tk):
        self.root = root
        root.title(APP_TITLE)
        root.geometry("720x480")
        self.files = []
        self.log_q = queue.Queue()
        self.worker_thread = None
        self._build_ui()
        self._poll_log()

    def _build_ui(self):
        frm = ttk.Frame(self.root, padding=10)
        frm.pack(fill=tk.BOTH, expand=True)

        # File list + buttons
        left = ttk.Frame(frm)
        left.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.listbox = tk.Listbox(left, selectmode=tk.EXTENDED)
        self.listbox.pack(fill=tk.BOTH, expand=True, side=tk.TOP)

        btn_row = ttk.Frame(left)
        btn_row.pack(fill=tk.X, pady=6)
        ttk.Button(btn_row, text="Add Files...", command=self.add_files).pack(side=tk.LEFT)
        ttk.Button(btn_row, text="Remove Selected", command=self.remove_selected).pack(side=tk.LEFT, padx=6)
        ttk.Button(btn_row, text="Clear", command=self.clear_files).pack(side=tk.LEFT)

        # Controls and progress
        right = ttk.Frame(frm, width=240)
        right.pack(side=tk.RIGHT, fill=tk.Y)

        self.start_btn = ttk.Button(right, text="Start Scrub", command=self.start)
        self.start_btn.pack(fill=tk.X, pady=(0,6))

        self.progress = ttk.Progressbar(right, orient="horizontal", length=200, mode="determinate")
        self.progress.pack(fill=tk.X, pady=(0,6))

        ttk.Label(right, text="Virtual Output:").pack(anchor="w")
        self.vout_entry = ttk.Entry(right)
        self.vout_entry.insert(0, VIRTUAL_OUTPUT_NAME)
        self.vout_entry.pack(fill=tk.X, pady=(0,6))

        ttk.Label(right, text="Virtual Input:").pack(anchor="w")
        self.vin_entry = ttk.Entry(right)
        self.vin_entry.insert(0, VIRTUAL_INPUT_NAME)
        self.vin_entry.pack(fill=tk.X, pady=(0,6))

        self.bitrate_var = tk.StringVar(value=CODEC_BITRATE or "")
        ttk.Label(right, text="Neural Bitrate (empty to skip):").pack(anchor="w")
        ttk.Entry(right, textvariable=self.bitrate_var).pack(fill=tk.X)

        # Log window
        log_frame = ttk.LabelFrame(self.root, text="Log")
        log_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=6)
        self.log_widget = scrolledtext.ScrolledText(log_frame, height=10, state="disabled")
        self.log_widget.pack(fill=tk.BOTH, expand=True)

    def add_files(self):
        files = filedialog.askopenfilenames(title="Select audio files", filetypes=[("Audio files", "*.mp3 *.wav *.flac *.m4a"), ("All files", "*.*")])
        for f in files:
            if f not in self.files:
                self.files.append(f)
                self.listbox.insert(tk.END, f)

    def remove_selected(self):
        sel = list(self.listbox.curselection())
        for idx in reversed(sel):
            self.listbox.delete(idx)
            del self.files[idx]

    def clear_files(self):
        self.listbox.delete(0, tk.END)
        self.files.clear()

    def start(self):
        if self.worker_thread and self.worker_thread.is_alive():
            messagebox.showinfo("Running", "Processing already in progress.")
            return
        if not self.files:
            messagebox.showwarning("No files", "Add at least one file to process.")
            return
        # disable UI
        self.start_btn.config(state=tk.DISABLED)
        self.progress["maximum"] = len(self.files)
        self.progress["value"] = 0
        self.worker_thread = threading.Thread(target=self._worker, daemon=True)
        self.worker_thread.start()

    def _worker(self):
        vout = self.vout_entry.get().strip()
        vin = self.vin_entry.get().strip()
        bitrate = self.bitrate_var.get().strip() or None

        def log_cb(s):
            self.log_q.put(s)

        total = len(self.files)
        for idx, path in enumerate(list(self.files), start=1):
            try:
                log_cb(f"Processing {path} ({idx}/{total})")
                base, _ = os.path.splitext(path)
                temp = f"{base}_rerecord.wav"
                final = f"{base}_clean.wav"
                # call re-record
                rerecord(path, temp, vout_name=vout, vin_name=vin, log=log_cb)
                if bitrate:
                    # run neural scrub
                    try:
                        neural_scrub(temp, final, bitrate=bitrate, log=log_cb)
                        try:
                            os.remove(temp)
                        except Exception:
                            pass
                    except Exception as e:
                        log_cb(f"Neural scrub failed: {e}")
                        # keep temp for inspection
                else:
                    os.replace(temp, final)
                log_cb(f"  → {final}")
            except Exception as e:
                log_cb(f"Error processing {path}: {e}")
            finally:
                self.log_q.put(("PROGRESS", idx))
        self.log_q.put("DONE")

    def _poll_log(self):
        try:
            while True:
                item = self.log_q.get_nowait()
                if isinstance(item, tuple) and item[0] == "PROGRESS":
                    _, idx = item
                    self.progress["value"] = idx
                    continue
                if item == "DONE":
                    self.start_btn.config(state=tk.NORMAL)
                    self.log("All done.")
                    continue
                self.log(item)
        except queue.Empty:
            pass
        self.root.after(150, self._poll_log)

    def log(self, text: str):
        self.log_widget.config(state="normal")
        self.log_widget.insert(tk.END, text + "\n")
        self.log_widget.see(tk.END)
        self.log_widget.config(state="disabled")

def main():
    root = tk.Tk()
    app = App(root)
    root.mainloop()

if __name__ == "__main__":
    main()
