import os
import re

root_folder = "resources"

for dirpath, dirnames, filenames in os.walk(root_folder):
    for filename in filenames:
        old_path = os.path.join(dirpath, filename)

        if os.path.isfile(old_path):
            match = re.search(r"(\d+)", filename)
            if match:
                number = match.group(1)  # Keeps leading zeroes like "007"
                ext = os.path.splitext(filename)[1]
                new_name = f"{number}{ext}"
                new_path = os.path.join(dirpath, new_name)

                # Avoid overwriting files
                if not os.path.exists(new_path):
                    os.rename(old_path, new_path)
                    print(f"Renamed {filename} → {new_name}")
                else:
                    print(f"Skipped {filename}: target {new_name} already exists")
            else:
                print(f"Skipped {filename}: no number found")
