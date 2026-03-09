import os
import re

def fix():
    files_with_dups = set()
    with open('out_utf8.txt', 'r', encoding='utf8') as f:
        for line in f:
            if 'duplicate_constructor' in line:
                parts = line.split(' - ')
                if len(parts) >= 2:
                    file_path = parts[1].split(':')[0].strip()
                    files_with_dups.add(file_path)
    
    for file_path in files_with_dups:
        if not os.path.exists(file_path):
            continue
        with open(file_path, 'r', encoding='utf8') as f:
            lines = f.readlines()
        
        # Find all classes
        class_names = []
        for line in lines:
            m = re.match(r'^\s*class\s+(\w+)\s+extends', line)
            if m:
                class_names.append(m.group(1))
        
        # To decide which constructor to delete, we find them first
        for cls in class_names:
            idx_const_empty = -1
            idx_non_const_empty = -1
            idx_other = -1
            
            for i, line in enumerate(lines):
                stripped = line.strip()
                if stripped == f"const {cls}({{super.key}});":
                    idx_const_empty = i
                elif stripped == f"{cls}({{super.key}});":
                    idx_non_const_empty = i
                elif stripped.startswith(f"{cls}(") or stripped.startswith(f"const {cls}("):
                    if stripped != f"const {cls}({{super.key}});" and stripped != f"{cls}({{super.key}});":
                        idx_other = i
                        
            # Delete logic
            if idx_const_empty != -1 and idx_non_const_empty != -1:
                # Delete non_const empty
                lines[idx_non_const_empty] = None
                print(f"Deleted non-const empty constructor in {file_path}")
            elif idx_const_empty != -1 and idx_other != -1:
                # Delete empty const because the other has params
                lines[idx_const_empty] = None
                print(f"Deleted const empty constructor in {file_path}")
            elif idx_non_const_empty != -1 and idx_other != -1:
                lines[idx_non_const_empty] = None
                print(f"Deleted non-const empty constructor in {file_path}")

        with open(file_path, 'w', encoding='utf8') as f:
            for line in lines:
                if line is not None:
                    f.write(line)

fix()
