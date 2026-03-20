import os
from typing import Optional, List
import csv
import json
from typing import Union

csv_folder = "student_csv"
students_file = "students.json"

def find_first_csv(root: str = f"{csv_folder}") -> Optional[str]:
    """Return the first .csv file found under root, or None if none exist."""
    files = [os.path.join(csv_folder, f) for f in os.listdir(root) if f.lower().endswith(".csv")]
    return files[0] if files else None

def csv_to_json(csv_path: str, encoding: str = "utf-8-sig", as_string: bool = False):
    """Parse a CSV file into a list of dicts using the header row as keys.
    If as_string is True, return a JSON string; otherwise return a Python list of dicts.
    """

    csv_path = os.path.abspath(os.path.expanduser(csv_path))
    if not os.path.exists(csv_path) or not os.path.isfile(csv_path):
        return json.dumps([]) if as_string else []

    with open(csv_path, newline="", encoding=encoding) as f:
        reader = csv.DictReader(f)
        rows = [dict(row) for row in reader][1:]

    return json.dumps(rows, ensure_ascii=False) if as_string else rows

def main():
    csv_file = find_first_csv()
    if not csv_file:
        print(f"No CSV files found under /{csv_folder}")
        return
    print(f"Found CSV file: {csv_file}")
    data = csv_to_json(csv_file)
    
    with open(students_file, "w") as f:
        f.write(json.dumps(data, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()