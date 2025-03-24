# MATLAB Assignments

This repository contains MATLAB assignments and solutions for Jacob Koziej's ECE-211 MATLAB course.

## Structure

- `home solutions/` - Directory containing MATLAB solution files
  - `assignment03.m` - Solution for Assignment 3
  - `assignment_one.m` - Solution for Assignment 1
  - `assignment_two.m` - Solution for Assignment 2
  - `assignment_three.m` - Solution for Assignment 3
  - `assignment_four.m` - Solution for Assignment 4
  - `assignment_five.m` - Solution for Assignment 5
  - `assignment_six.m` - Solution for Assignment 6
  - `assignment_seven.m` - Solution for Assignment 7
  - `assignment_eight.m` - Solution for Assignment 8
- `school materials/assignments/` - Course assignment PDFs

## Getting Started

### Prerequisites

- MATLAB (any recent version should work)
- Python 3.7+ (for development tools)
- pyenv (recommended for Python version management)

### Usage

`source ~/.venv/miss_hit/bin/activate && cd "home solutions" && mh_style assignment_*.m` - to very quickly find the pattern.

## Development Setup

### Setting up Development Environment

1. Set up Python environment:
```bash
# Create and activate virtual environment
python -m venv ~/.venv/miss_hit
source ~/.venv/miss_hit/bin/activate  # On Windows: .venv\miss_hit\Scripts\activate

# Install MISS_HIT
pip install miss-hit-core
```

2. Add convenient alias to your shell config:
```bash
echo 'alias mh_style="source ~/.venv/miss_hit/bin/activate && mh_style"' >> ~/.zshrc
source ~/.zshrc
```

### Running Solutions

1. Open MATLAB
2. Navigate to the solution directory
3. Run the desired .m file
4. or use in the specific directory use `matlab -batch "assignment_four"`

### Style Checking

The repository includes a `.miss_hit` configuration file that ensures consistent style across all MATLAB files.

To check your code style:
```bash
mh_style assignment_*.m
```
or
```bash
mh_style "home solutions/assignment_four.m"
```

Style rules include:
- 80 character line length
- Consistent file naming (assignment_*.m)
- Proper spacing and indentation
- Clear commenting guidelines

### Contributing

1. Ensure you have set up the development environment as described above
2. Make your changes
3. Run style checks before committing
4. Fix any style issues before pushing your changes

### Optional: Git Hooks

To automatically check style before commits:
```bash
# Create pre-commit hook
echo '#!/bin/bash
source ~/.venv/miss_hit/bin/activate
mh_style assignment_*.m' > .git/hooks/pre-commit

# Make it executable
chmod +x .git/hooks/pre-commit
```
